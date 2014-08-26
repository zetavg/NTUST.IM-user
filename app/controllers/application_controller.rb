class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :get_app_setting
  before_action :save_page_history
  after_action :login_control

  def doorkeeper_unauthorized_render_options
    {:json => {:error => {:message => "Not authorized", :code => 401}}}
  end

  private

  def get_app_setting
    # The settings are loaded with '/app/models/setting.rb'
    @app_name = Setting.app_name
    @google_analytics_id = Setting.google_analytics_id
    Setting['email_regexp'] = /#{Setting.email_regexp_s}/
    Setting['email_analysis_regexp'] = /#{Setting.email_analysis_regexp_s}/
  end

  def save_page_history
    (session[:page_history] ||= []).unshift request.fullpath
    session[:page_history].pop if session[:page_history].length > 4
  end

  def login_control
    if current_user
      cookies[:user_logined] = { value: true, domain: Setting.app_domain.gsub(/^[^\.]*/, '') }
    else
      cookies[:user_logined] = { value: false, domain: Setting.app_domain.gsub(/^[^\.]*/, '') }
    end
  end
end
