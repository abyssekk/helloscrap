class Admin::BoardsController < Admin::BaseController

    def index
        @q = Board.ransack(params[:q])
        @boards = @q.result(distinct: true).order('created_at DESC').page(params[:page])
    end

    def show
        @board = Board.find(params[:id])
    end

    def edit
        @board = Board.find(params[:id])
    end

    def update
        @board = Board.find(params[:id])
        if @board.update(board_params)
            redirect_to admin_board_path(@board)
            flash[:success] = t('defaults.updated')
        else
            flash.now[:danger] = t('defaults.not_updated')
            render :edit
        end
    end

    def destroy
        @board = Board.find(params[:id])
        @board.destroy!
        redirect_to admin_boards_path, success: t('defaults.deleted')
    end

    private

    def board_params
        params.require(:board).permit(:title, :body, :url, :notice)
    end
end
