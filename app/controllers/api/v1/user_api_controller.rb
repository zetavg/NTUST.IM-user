class Api::V1::UserApiController < ApplicationController
  before_action :check_permissions
  respond_to     :json
  protect_from_forgery

  swagger_controller :user, "使用者存取相關 API"

  swagger_api :user_data do
    summary "取得指定使用者資料"
    notes "透過 access token 取得其擁有者的基本資料。需要 offline_access 權限，回傳資料因 access token 的 scope 而異。"
    param :path, :user_id, :integer, :required, "使用者 ID"
    param :query, :application_id, :string, :required, "應用程式 ID"
    param :query, :secret, :string, :required, "應用程式秘鑰"
    response :unauthorized
    response :not_found, 'Not Found 沒有此使用者'
  end

  def user_data
    if !User.where('id = ?', params['id']).first
      render json: {:error => {:message => "User not found", :code => 404}, :status => 404}, status: 404
    else
      a = Doorkeeper::Application.where(["uid = ? and secret = ?", params['application_id'].tr('^A-Za-z0-9', ''), params['secret'].tr('^A-Za-z0-9', '')]).first
      t = a.access_tokens.where('resource_owner_id', params['id'].tr('^0-9', '')).order('created_at DESC').first
      respond_with User.find(params['id'].tr('^0-9', '')).api_get_data(t.scopes, is_admin?)
    end
  end

  swagger_api :send_sms do
    summary "傳送簡訊給指定使用者"
    notes "傳送簡訊到 access token 擁有者的手機號碼 (若已認證)。需要 sms 與 offline_access 權限。"
    param :path, :user_id, :integer, :required, "使用者 ID"
    param :query, :application_id, :string, :required, "應用程式 ID"
    param :query, :secret, :string, :required, "應用程式秘鑰"
    response :unauthorized
    response :too_many_requests, 'Too Many Requests 超出發送量限制'
    response :not_found, 'Not Found 沒有此使用者，或該使用者沒有填寫手機號碼'
    response :service_unavailable, 'Service Unavailable 簡訊無法送出'
    response :unauthorized
  end

  def send_sms
    if !User.where('id = ?', params['id']).first
      render json: {:error => {:message => "User not found", :code => 404}, :status => 404}, status: 404
    else
      a = Doorkeeper::Application.where(["uid = ? and secret = ?", params['application_id'].tr('^A-Za-z0-9', ''), params['secret'].tr('^A-Za-z0-9', '')]).first
      t = a.access_tokens.where('resource_owner_id', params['id'].tr('^0-9', '')).order('created_at DESC').first
      respond = User.find(params['id'].tr('^0-9', '')).api_send_sms(params['message'], a.id, t.scopes, is_admin?)
      render json: respond, status: respond[:status]
    end
  end

  private

  def current_resource_owner
    User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
  end

  def check_permissions
    a = Doorkeeper::Application.where(["uid = ? and secret = ?", params['application_id'].tr('^A-Za-z0-9', ''), params['secret'].tr('^A-Za-z0-9', '')]).first
    if a
      t = a.access_tokens.where('resource_owner_id', params['id'].tr('^0-9', '')).order('created_at DESC').first
      if t && !t.revoked_at && t.scopes.include?('offline_access')
        return true
      elsif is_admin?
        return true
      else
        render json: {:error => {:message => "Not authorized", :code => 401}, :status => 401}, status: 401
        return false
      end
    else
      render json: {:error => {:message => "Bad application ID or secret", :code => 401}, :status => 401}, status: 401
      return false
    end
  end

  def is_admin?
    admin = false
    a = Doorkeeper::Application.where(["uid = ? and secret = ?", params['application_id'].tr('^A-Za-z0-9', ''), params['secret'].tr('^A-Za-z0-9', '')]).first
    if a
      if a.owner.admin?
        admin = true
      end
    end
    admin
  end
end
