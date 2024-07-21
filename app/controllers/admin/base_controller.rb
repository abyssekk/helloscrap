class Admin::BaseController < ApplicationController
    before_action :check_admin
    layout 'admin/layouts/application'

    private

    def logged_in?
        !current_user.nil?
    end

    def check_admin
        if logged_in?
            unless current_user.admin?
                redirect_to root_path
            end
        else
            redirect_to admin_login_path
        end
    end
end
