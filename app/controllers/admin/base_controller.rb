class Admin::BaseController < ApplicationController
    before_action :check_admin
    layout 'admin/layouts/application'

    private

    def check_admin
        unless current_user.admin?
            redirect_to root_path
        end
    end
end
