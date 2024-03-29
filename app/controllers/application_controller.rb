class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :check_url
  before_filter :get_app_setting
  before_action :save_page_history
  after_action :login_control

  def doorkeeper_unauthorized_render_options
    {:json => {:error => {:message => "Not authorized", :code => 401}}}
  end

  private

  def check_url
    if !request.original_url.match(/#{Setting.app_url.gsub(/\/$/, '')}/)
      redirect_to(Setting.app_url.gsub(/\/$/, '') + request.fullpath) && return
    end
  end

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
      t = Time.now.to_i.to_s
      cookies[:login_token_gtime] = { value: t, domain: '.' + Setting.app_domain }
      cookies[:login_token] = { value: Digest::MD5.hexdigest(Setting.site_secret_key + t + current_user.id.to_s), domain: '.' + Setting.app_domain }
    else
      cookies[:login_token] = { value: '', domain: '.' + Setting.app_domain }
    end
  end
end
