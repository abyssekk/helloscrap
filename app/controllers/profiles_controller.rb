class ProfilesController < ApplicationController
    before_action :set_user, only: %i[edit update]

    def show; end
    def edit; end

    def update
        if @user.update(profile_params)
            redirect_to profile_path
            flash[:success] = t('defaults.updated')
        else
            flash.now[:danger] = t('defaults.not_updated')
            render :edit
        end
    end

    private

    def profile_params
        params.require(:user).permit(:email, :nickname)
    end

    def set_user
        @user = User.find(current_user.id)
    end
end
