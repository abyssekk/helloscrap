class BoardsController < ApplicationController
    def new
        @board = Board.new
        if session[:url] then
            @board = Board.new(title: session[:url], body: session[:url], url: session[:url])
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
