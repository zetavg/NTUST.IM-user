class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :get_app_setting

  private

  def get_app_setting
    # The settings are loaded with '/app/models/setting.rb'
    @app_name = Setting.app_name
    @google_analytics_id = Setting.google_analytics_id
    Setting['email_regexp'] = /#{Setting.email_regexp_s}/
    Setting['email_analysis_regexp'] = /#{Setting.email_analysis_regexp_s}/
  end
end
