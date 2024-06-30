class Admin::UserSessionsController < Admin::BaseController
    skip_before_action :check_admin, only: %i[new create]
    layout 'admin/layouts/admin_login'

    def new; end

    def create
        @user = login(params[:email], params[:password])
        if @user
            redirect_to admin_root_path
        else
            flash.now[:danger] = 'ログインに失敗しました'
            render :new
        end
    end

    def destroy
        logout
        redirect_to admin_login_path
    end
end
