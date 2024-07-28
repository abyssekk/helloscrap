# Hello Scrap
インターネット記事の保存用サイトです。<br>
スクラップの際に、紙の記事であれば切り抜きます。<br>
当サービスを使えば、インターネットの記事もURLからスクラップ(自動抽出)し感想と共に保存できます。<br>

# URL
https://helloscrap.app/

# デモ

https://github.com/user-attachments/assets/903a5c6d-4069-4735-9705-6bd427f7deb1

# 使用技術
- Ruby 2.6.9
- Ruby on Rails 5.2.6
- Heroku

# 機能一覧
- ユーザー登録・ログイン機能・パスワードリセット機能(sorcery)
- 投稿機能(作成・編集・削除)
    - 抽出機能
    - リッチテキストエディタ機能(summernote)
- 検索機能(ransack)
- ページネーション機能(kaminari)
- 投稿履歴のグラフ化機能(chartkick)
- 管理者機能
    - ユーザーの編集・削除
    - 投稿内容の編集・削除

# その他
- サイトによっては記事のタイトル・内容を自動抽出できないことがあります。
