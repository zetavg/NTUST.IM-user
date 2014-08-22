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
end
