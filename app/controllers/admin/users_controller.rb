class Admin::UsersController < Admin::BaseController
    def index
        @users = User.order('created_at DESC').page(params[:page])
    end

    def show
        @user = User.find(params[:id])
    end

    def edit
        @user = User.find(params[:id])
    end

    def update
        @user = User.find(params[:id])
        if @user.update(profile_params)
            redirect_to admin_user_path(@user)
            flash[:success] = t('defaults.updated')
        else
            flash.now[:danger] = t('defaults.not_updated')
            render :edit
        end
    end

    def destroy
        @user = User.find(params[:id])
        @user.destroy!
        redirect_to admin_users_path, success: t('defaults.deleted')
    end

    private

    def profile_params
        params.require(:user).permit(:email, :nickname, :role)
    end
end
