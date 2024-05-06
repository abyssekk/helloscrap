class BoardsController < ApplicationController
    def new
        @board = Board.new
    end

    def create
        @board = current_user.boards.build(board_params)
        print(board_params[:title])
        if @board.save
            redirect_to boards_path
            flash[:success] = t('.success')
        else
            flash.now[:danger] = t('.fail')
            render :new
        end
    end

    def edit
        @board = current_user.boards.find(params[:id])
    end

    def update
        @board = Board.find(params[:id])
        if @board.update(board_params)
            redirect_to board_path(@board)
            flash[:success] = t('defaults.updated')
        else
            flash.now[:danger] = t('defaults.not_updated')
            render :new
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
        params.require(:board).permit(:title, :body)
    end

    def extract
        html = params[:url]
        body, title = ExtractContent::analyse(html)
    end
end
