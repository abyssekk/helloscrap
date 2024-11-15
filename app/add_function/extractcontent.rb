#!/usr/bin/ruby -Ku
# encoding: UTF-8

# Author:: Nakatani Shuyo
# Copyright:: (c)2007 Cybozu Labs Inc. All rights reserved.
# License:: BSD

# Extract Content Module for html
# ExtractContent : 本文抽出モジュール
#
# 与えられた html テキストから本文と思わしきテキストを抽出します。
# - html をブロックに分離、スコアの低いブロックを除外
# - 評価の高い連続ブロックをクラスタ化し、クラスタ間でさらに比較を行う
# - スコアは配置、テキスト長、アフィリエイトリンク、フッタ等に特有のキーワードが含まれているかによって決定
# - Google AdSense Section Target ブロックには本文が記述されているとし、特に抽出

module ExtractContent
  # Default option parameters.
  @default = {
    :threshold => 100,                                                # 本文と見なすスコアの閾値
    :min_length => 80,                                                # 評価を行うブロック長の最小値
    :decay_factor => 0.73,                                            # 減衰係数(小さいほど先頭に近いブロックのスコアが高くなる)
    :continuous_factor => 1.62,                                       # 連続ブロック係数(大きいほどブロックを連続と判定しにくくなる)
    :punctuation_weight => 10,                                        # 句読点に対するスコア
    :punctuations => /([、。，．！？]|\.[^A-Za-z0-9]|,[^0-9]|!|\?)/,  # 句読点
    :waste_expressions => /Copyright|All Rights Reserved/i,           # フッターに含まれる特徴的なキーワードを指定
    :debug => false,                                                  # true の場合、ブロック情報を標準出力に
  }

  # 実体参照変換
  CHARREF = {
    '&nbsp;' => ' ',
    '&lt;'   => '<',
    '&gt;'   => '>',
    '&amp;'  => '&',
    '&laquo;'=> "\xc2\xab",
    '&raquo;'=> "\xc2\xbb",
  }

  # Sets option parameters to default.
  # Parameter opt is given as Hash instance.
  # デフォルトのオプション値を指定する。
  # 引数は @default と同じ形式で与える。
  def self.set_default(opt)
    @default.update(opt) if opt
  end

  # Analyses the given HTML text, extracts body and title.
  def self.analyse(html, opt=nil)
    # frameset or redirect
    return ["", extract_title(html)] if html =~ /<\/frameset>|<meta\s+http-equiv\s*=\s*["']?refresh['"]?[^>]*url/i

    # option parameters
    opt = if opt then @default.merge(opt) else @default end
    b = binding   # local_variable_set があれば……
    threshold=min_length=decay_factor=continuous_factor=punctuation_weight=punctuations=waste_expressions=debug=nil
    opt.each do |key, value|
      eval("#{key.id2name} = opt[:#{key.id2name}]", b) 
    end

    # header & title
    title = if html =~ /<\/head\s*>/im
      html = $' #'
      extract_title($`)
    else
      extract_title(html)
    end

    # Google AdSense Section Target
    html.gsub!(/<!--\s*google_ad_section_start\(weight=ignore\)\s*-->.*?<!--\s*google_ad_section_end.*?-->/m, '')
    if html =~ /<!--\s*google_ad_section_start[^>]*-->/n
      html = html.scan(/<!--\s*google_ad_section_start[^>]*-->.*?<!--\s*google_ad_section_end.*?-->/mn).join("\n")
    end

    # eliminate useless text
    html = eliminate_useless_tags(html)

    # h? block including title
    html.encode!('UTF-8', 'UTF-8', invalid: :replace, undef: :replace)
    title.encode!('UTF-8', 'UTF-8', invalid: :replace, undef: :replace)
    html.gsub!(Regexp.new('(<h\d\s*>\s*(.*?)\s*<\/h\d\s*>)', Regexp::IGNORECASE | Regexp::MULTILINE)) do |m|
      if $2.length >= 3 && title.include?($2) then "<div>#{$2}</div>" else $1 end
    end

    # extract text blocks
    factor = continuous = 1.0
    body = ''
    score = 0
    bodylist = []
    list = html.split(/<\/?(?:div|center|td)[^>]*>|<p\s*[^>]*class\s*=\s*["']?(?:posted|plugin-\w+)['"]?[^>]*>/)
    list.each do |block|
      next unless block
      block.strip!
      next if has_only_tags(block)
      continuous /= continuous_factor if body.length > 0

      # リンク除外＆リンクリスト判定
      notlinked = eliminate_link(block)
      next if notlinked.length < min_length

      # スコア算出
      c = (notlinked.length + notlinked.scan(punctuations).length * punctuation_weight) * factor
      factor *= decay_factor
      not_body_rate = block.scan(waste_expressions).length + block.scan(/amazon[a-z0-9\.\/\-\?&]+-22/i).length / 2.0
      c *= (0.72 ** not_body_rate) if not_body_rate>0
      c1 = c * continuous
      puts "----- #{c}*#{continuous}=#{c1} #{notlinked.length} \n#{strip_tags(block)[0,100]}\n" if debug

      # ブロック抽出＆スコア加算
      if c1 > threshold
        body += block + "\n"
        score += c1
        continuous = continuous_factor
      elsif c > threshold # continuous block end
        bodylist << [body, score]
        body = block + "\n"
        score = c
        continuous = continuous_factor
      end
    end
    bodylist << [body, score]
    body = bodylist.inject{|a,b| if a[1]>=b[1] then a else b end }
    [strip_tags(body[0]), title]
  end

  # Extracts title.
  def self.extract_title(st)
    if st =~ /<title[^>]*>\s*(.*?)\s*<\/title\s*>/i
      strip_tags($1)
    else
      ""
    end
  end

  private

  # Eliminates useless tags
  def self.eliminate_useless_tags(html)
    html.encode!('UTF-8', 'UTF-8', invalid: :replace, undef: :replace)
    # eliminate useless symbols
    html.gsub!(/[\u2018-\u201d\u2190-\u2193\u25a0-\u25bd\u25c6-\u25ef\u2605-\u2606]/, '')

    # eliminate useless html tags
    html.gsub!(/<(script|style|select|noscript)[^>]*>.*?<\/\1\s*>/imn, '')
    html.gsub!(/<!--.*?-->/m, '')
    html.gsub!(/<![A-Za-z].*?>/m, '')
    html.gsub!(/<div\s[^>]*class\s*=\s*['"]?alpslab-slide["']?[^>]*>.*?<\/div\s*>/m, '')
    html.gsub!(/<div\s[^>]*(id|class)\s*=\s*['"]?\S*more\S*["']?[^>]*>/i, '')

    html
  end

  # Checks if the given block has only tags without text.
  def self.has_only_tags(st)
    st.gsub(/<[^>]*>/imn, '').gsub("&nbsp;",'').strip.length == 0
  end

  # リンク除外＆リンクリスト判定
  def self.eliminate_link(html)
    count = 0
    notlinked = html.gsub(/<a\s[^>]*>.*?<\/a\s*>/imn){count+=1;''}.gsub(/<form\s[^>]*>.*?<\/form\s*>/imn, '')
    notlinked = strip_tags(notlinked)
    return "" if notlinked.length < 20 * count || islinklist(html)
    return notlinked
  end

  # リンクリスト判定
  # リストであれば非本文として除外する
  def self.islinklist(st)
    if st=~/<(?:ul|dl|ol)(.+?)<\/(?:ul|dl|ol)>/im
      listpart = $1
      outside = st.gsub(/<(?:ul|dl)(.+?)<\/(?:ul|dl)>/ismn, '').gsub(/<.+?>/mn, '').gsub(/\s+/, ' ')
      list = listpart.split(/<li[^>]*>/)
      list.shift
      rate = evaluate_list(list)
      outside.length <= st.length / (45 / rate)
    end
  end

  # リンクリストらしさを評価
  def self.evaluate_list(list)
    return 1 if list.length == 0
    hit = 0
    list.each do |line|
      hit +=1 if line =~ /<a\s+href=(['"]?)([^"'\s]+)\1/imn
    end
    return 9 * (1.0 * hit / list.length) ** 2 + 1
  end

  # Strips tags from html.
  def self.strip_tags(html)
    st = html.gsub(/<.+?>/m, '')
    # Convert from wide character to ascii
    # symbols, 0-9, A-Z
    #st.gsub!(/\357\274([\201-\272])/){($1[0]-96).chr}
    # a-z
    #st.gsub!(/\357\275([\201-\232])/){($1[0]-32).chr}
    if !st.is_a?(String)
      require 'unicode_normalize'
      st = Unicode::Normalize.nfkc(st.to_s)
      st = st.encode('utf-8')
    end
    st.encode!('UTF-8', 'UTF-8', invalid: :replace, undef: :replace)
    # keisen
    st.gsub!(/\u2014|\u2015|\u3000/, '')
    self::CHARREF.each { |ref, c| st.gsub!(ref.encode(Encoding::UTF_8), c) }
    require 'cgi'
    st = CGI.unescapeHTML(st)
    st.gsub(/[ \t]+/, " ")
    st.gsub(/\n\s*/, "\n")
  end

end
