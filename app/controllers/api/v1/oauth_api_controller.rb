class Api::V1::OauthApiController < ApplicationController
  doorkeeper_for :all
  respond_to     :json
  protect_from_forgery

  swagger_controller :users, "OAuth 2.0 User 相關 API"

  swagger_api :me do
    summary "取得使用者資料"
    notes "透過 access token 取得其擁有者的基本資料。回傳資料因 access token 的 scope 而異。"
    param :query, :access_token, :string, :required, "access token"
    response :unauthorized
  end

  def me
    respond_with User.find(doorkeeper_token.resource_owner_id).api_get_data(doorkeeper_token.scopes, is_admin?)
  end

  swagger_api :send_sms do
    summary "傳送簡訊"
    notes "傳送簡訊到 access token 擁有者的手機號碼 (若已認證)。需要 sms 權限。"
    param :form, :access_token, :string, :required, "access token"
    param :form, :message, :string, :required, "簡訊內文"
    response :unauthorized
    response :too_many_requests, 'Too Many Requests 超出發送量限制'
    response :not_found, 'Not Found 該使用者沒有填寫手機號碼'
    response :service_unavailable, 'Service Unavailable 簡訊無法送出'
  end

  def send_sms
    respond = User.find(doorkeeper_token.resource_owner_id).api_send_sms(params['message'], doorkeeper_token.application_id, doorkeeper_token.scopes, is_admin?)
    render json: respond, status: respond[:status]
  end

  private

  def current_resource_owner
    User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
  end

  def is_admin?
    admin = false
    if doorkeeper_token.scopes.include?('admin')
      if doorkeeper_token.application.owner.admin?
        admin = true
      end
    end
    admin
  end
end
