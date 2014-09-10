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
    render json: User.find(doorkeeper_token.resource_owner_id).api_get_data(doorkeeper_token.scopes, is_admin?)
  end

  swagger_api :send_notification do
    summary "傳送通知"
    notes "傳送通知給 access token 擁有者。需要 notification 權限。"
    param :form, :access_token, :string, :required, "access token"
    param :form, :title, :string, :required, "通知標題"
    param :form, :type, :string, :optional, "通知類型"
    param :form, :content, :string, :optional, "通知內文"
    param :form, :url, :string, :optional, "通知連結網址"
    param :form, :priority, :integer, :optional, "通知急迫性，1 緊急 ~ 3 不緊急，0 代表非常緊急，若使用者有設定將此類通知轉發簡訊，將會送出簡訊並扣除簡訊額度 (轉發簡訊功能未實作)"
    param :form, :importance, :integer, :optional, "通知重要性，1 重要 ~ 3 不重要，0 將會置頂直到使用者進行動作"
    param :form, :image, :string, :optional, "圖片"
    # param :form, :sender, :string, :optional, "傳送者名稱，預設為應用程式名稱"
    # param :form, :sender_url, :string, :optional, "傳送者網址，預設為應用程式網址"
    param :form, :icon, :string, :optional, "圖示，預設為應用程式圖示"
    param :form, :event_name, :string, :optional, "事件名稱，配合特殊類型使用"
    param :form, :datetime, :string, :optional, "時間，配合特殊類型使用"
    param :form, :location, :string, :optional, "地點，配合特殊類型使用"
    response :unauthorized
  end

  def send_notification
    if doorkeeper_token.scopes.include?('notification') || is_admin?  # 有發送權
      respond = {:success => {:message => "Ok", :code => 200}, :status => 200}
      begin
        params[:sender] = nil
        params[:sender_url] = nil
        raise 'error' if !User.find(doorkeeper_token.resource_owner_id).send_notification(params[:title], params[:type], params[:content], params[:url], params[:image], doorkeeper_token.application_id, params[:priority], params[:importance], params[:sender], params[:sender_url], params[:icon], params[:event_name], params[:datetime], params[:location])
      rescue
        respond = {:success => {:message => "Error (Not found?)", :code => 404}, :status => 404}
      end
    else
      respond = {:error => {:message => "Not authorized", :code => 401}, :status => 401}
    end
    render json: respond, status: respond[:status]
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
      if doorkeeper_token.application.admin_app?
        admin = true
      end
    end
    admin
  end
end
