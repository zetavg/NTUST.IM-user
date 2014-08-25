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
