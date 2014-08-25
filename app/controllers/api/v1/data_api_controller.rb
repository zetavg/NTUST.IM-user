class Api::V1::DataApiController < ApplicationController
  respond_to     :json
  protect_from_forgery

  swagger_controller :data, "公開資料集 API"

  swagger_api :departments do
    summary "系所代碼"
    notes "取得系所及代碼資料。"
  end

  def departments
    render json: Department.all.select('code', 'name')
  end

  swagger_api :site_data do
    summary "本站資料"
    notes "本站資料。"
  end

  def site_data
    data = {}

    data['site_name'] = Setting.site_name
    data['org_name'] = Setting.org_name
    data['administrator_url'] = Setting.administrator_url
    data['administrator_email'] = Setting.administrator_email
    data['mailer_sender'] = Setting.mailer_sender
    data['google_analytics_id'] = Setting.google_analytics_id

    render json: data
  end

  swagger_api :site_navigation do
    summary "本站導航"
    notes "子網站導航。"
  end

  def site_navigation
    render json: Application.nav
  end

  swagger_api :site_menu do
    summary "本站選單"
    notes "子網站選單。"
  end

  def site_menu
    render json: Application.menu
  end
end
