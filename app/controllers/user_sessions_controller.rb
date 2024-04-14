class UserSessionsController < ApplicationController
    def new
    end

    def create
        @user = login(params[:email], params[:password])

        if @user
            redirect_to root_path
            flash[:success] = t('.success')
        else
            flash.now[:danger] = t('.fail')
            render :new
        end
    end

    def destroy
        logout
        redirect_to login_path
        flash[:success] = t('.success')
    end
end
