class BoardsController < ApplicationController
    require 'extractcontent.rb'
    require 'open-uri'
    
    def new
        @board = Board.new

        # とりあえず抽出実験してみた時の名残
        #url = 'https://k-tai.watch.impress.co.jp/docs/news/1592532.html'
        #html = URI.open(url).read
        #body, title = ExtractContent::analyse(html) 
        #p body

        if session[:url] then
            html = URI.open(session[:url]).read
            url_body, url_title = ExtractContent::analyse(html)
            @board = Board.new(title: url_title, body: url_body, url: session[:url])
            session.delete(:url)
        end
    end

    def create
        if params[:register] then
            @board = current_user.boards.build(board_params)
            if @board.save
                redirect_to boards_path
                flash[:success] = t('.success')
            else
                flash.now[:danger] = t('.fail')
                render :new
            end
        else
            session[:url] = board_params[:url]
            redirect_to new_board_path
        end
    end

    def edit
        @board = current_user.boards.find(params[:id])
        if session[:url] then
            @board.url = session[:url]
            @board.title = session[:url]
            @board.body = session[:url]
            session.delete(:url)
        end
    end

    def update
        if params[:register] then
            @board = Board.find(params[:id])
            if @board.update(board_params)
                redirect_to board_path(@board)
                flash[:success] = t('defaults.updated')
            else
                flash.now[:danger] = t('defaults.not_updated')
                render :new
            end
        else
            session[:url] = board_params[:url]
            redirect_to edit_board_path
        end
    end

    def index
        session.delete(:url) #いったん入れただけ。あとで削除する。
        @boards = Board.where(user_id: current_user.id).order('created_at DESC')
    end

    def show
        @board = Board.find(params[:id])
    end

    def destroy
        board = current_user.boards.find(params[:id])
        board.destroy
        redirect_to boards_url
        flash[:success] = t('defaults.deleted')
    end

    private

    def board_params
        params.require(:board).permit(:title, :body, :url)
    end

    def extract
        html = params[:url]
        body, title = ExtractContent::analyse(html)
    end
end
