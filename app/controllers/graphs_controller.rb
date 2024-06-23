class GraphsController < ApplicationController
    def show
        @period = params[:period]
        @chart = period_boards(@period)
    end

    private

    def period_boards(period)
        @boards = Board.where(user_id: current_user.id)
        current = Time.current.beginning_of_day
        end_date = Time.current
        case period
        when "week" then
            start_date = current.ago(6.days)
        when "month" then
            start_date = current.ago(1.month - 1.day)
        when "year" then
            start_date = current.ago(1.year - 1.day)
        else
            start_date = current.ago(6.days)
        end
        dates = []
        (start_date.to_datetime...end_date.to_datetime).each do |date|
            temp = []
            count = @boards.where(created_at: date.in_time_zone.all_day).count
            temp.push(date.to_date.strftime("%m-%d"), count)
            dates.push(temp)
        end
        return dates
    end
end
