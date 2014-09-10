class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def index
    limit = 50
    page = params[:page].to_i
    page -= 1 if page > 0
    offset = page * limit
    show_dismissed = params[:show_dismissed].to_s == 'true' ? true : false
    if show_dismissed
      @notifications = current_user.notifications.limit(limit).offset(offset).order('created_at DESC')
      @notifications_count = current_user.notifications.count
    else
      @notifications = current_user.notifications.where(dismissed: false).limit(limit).offset(offset).order('created_at DESC')
      @notifications_count = current_user.notifications.where(dismissed: false).count
    end
  end
end
