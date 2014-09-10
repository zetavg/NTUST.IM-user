class Api::V1::UserApiController < ApplicationController
  before_action :check_permissions, only: [:user_data, :send_sms]
  respond_to     :json
  protect_from_forgery

  swagger_controller :user, "使用者存取相關 API"

  swagger_api :user_data do
    summary "取得指定使用者資料"
    notes "透過 access token 取得其擁有者的基本資料。需要 offline_access 權限，回傳資料因 access token 的 scope 而異。"
    param :query, :application_id, :string, :required, "應用程式 ID"
    param :query, :secret, :string, :required, "應用程式密鑰"
    param :path, :id, :integer, :required, "使用者 ID"
    response :unauthorized
    response :not_found, 'Not Found 沒有此使用者'
  end

  def user_data
    if !User.where('id = ?', params['id']).first
      render json: {:error => {:message => "User not found", :code => 404}, :status => 404}, status: 404
    else
      a = Doorkeeper::Application.where(["uid = ? and secret = ?", params['application_id'].tr('^A-Za-z0-9', ''), params['secret'].tr('^A-Za-z0-9', '')]).first
      t = a.access_tokens.where('resource_owner_id = ?', params['id'].tr('^0-9', '')).order('created_at DESC').first
      if is_admin?
        scopes = ['admin']
      else
        scopes = t.scopes
      end
        render json: User.find(params['id'].tr('^0-9', '')).api_get_data(scopes, is_admin?)
    end
  end

  swagger_api :send_sms do
    summary "傳送簡訊給指定使用者"
    notes "傳送簡訊到 access token 擁有者的手機號碼 (若已認證)。需要 sms 與 offline_access 權限。"
    param :form, :application_id, :string, :required, "應用程式 ID"
    param :form, :secret, :string, :required, "應用程式密鑰"
    param :path, :id, :integer, :required, "使用者 ID"
    param :form, :message, :string, :required, "簡訊內文"
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
      t = a.access_tokens.where('resource_owner_id = ?', params['id'].tr('^0-9', '')).order('created_at DESC').first
      if is_admin?
        scopes = ['admin']
      else
        scopes = t.scopes
      end
      respond = User.find(params['id'].tr('^0-9', '')).api_send_sms(params['message'], a.id, scopes, is_admin?)
      render json: respond, status: respond[:status]
    end
  end


  swagger_api :list_users do
    summary "列出使用者"
    notes "僅供 admin 使用。"
    param :query, :application_id, :string, :required, "應用程式 ID"
    param :query, :secret, :string, :required, "應用程式密鑰"
    param :path, :admission_year, :string, :required, "入學年，數字或 'all'"
    # param :path, :college_code, :string, :required, "學院 CODE，或 'all'"
    param :path, :department_code, :string, :required, "系所 CODE，或 'all'"
    response :unauthorized
    response :not_found, 'Not Found 沒有此使用者'
  end

  def list_users
    if is_admin?
      begin
        # if params[:college_code] == 'all'
          if params[:department_code] == 'all'
            users = User
          else
            users = Department.where("code = ?", params[:department_code]).first.students
          end
        # else
        #   if params[:department_code] == 'all'
        #     users = College.where("code = ?", params[:college_code]).first.students
        #   else
        #     users = College.where("code = ?", params[:college_code]).first.departments.where("code = ?", params[:department_code]).first.students
        #   end
        # end
        if params[:admission_year] == 'all'
          result = users.confirmed.all.select(:id, :name, :email, :admission_year, :department_code)
        else
          result = users.confirmed.where("admission_year = ?", params[:admission_year]).all.select(:id, :name, :email, :admission_year, :department_code)
        end
        render json: result
      rescue
        render json: {:error => {:message => "Not found", :code => 404}, :status => 404}, status: 404
      end
    else
      render json: {:error => {:message => "Not authorized", :code => 401}, :status => 401}, status: 401
    end
  end

  swagger_api :find_user do
    summary "條件尋找使用者"
    notes "僅供 admin 使用。尋找條件參數擇一填寫。"
    param :query, :application_id, :string, :required, "應用程式 ID"
    param :query, :secret, :string, :required, "應用程式密鑰"
    param :query, :fbid, :string, :optional, "Facebook ID"
    param :query, :sid, :string, :optional, "學號"
    param :query, :name, :string, :optional, "名稱"
    param :query, :email, :string, :optional, "email"
    response :unauthorized
    response :not_found, 'Not Found 沒有此使用者'
  end

  def find_user
    if is_admin?
      begin
        if params[:fbid].to_s != ''
          result = User.confirmed.where(fbid: params[:fbid]).all
        elsif params[:sid].to_s != ''
          result = User.confirmed.where(student_id: params[:sid]).all
        elsif params[:name].to_s != ''
          result = User.confirmed.where(name: params[:name]).all
        elsif params[:email].to_s != ''
          result = User.confirmed.where(email: params[:email]).all
        end

        raise 'Not found' if !result || result.count == 0

        render json: result
      rescue
        render json: {:error => {:message => "Not found", :code => 404}, :status => 404}, status: 404
      end
    else
      render json: {:error => {:message => "Not authorized", :code => 401}, :status => 401}, status: 401
    end
  end

  private

  def current_resource_owner
    User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
  end

  def check_permissions
    if (params['application_id'].to_s == '' || params['secret'].to_s == '')
      render json: {:error => {:message => "Bad application ID or secret", :code => 401}, :status => 401}, status: 401
      return false
    end
    a = Doorkeeper::Application.where(["uid = ? and secret = ?", params['application_id'].tr('^A-Za-z0-9', ''), params['secret'].tr('^A-Za-z0-9', '')]).first
    if a
      t = a.access_tokens.where('resource_owner_id = ?', params['id'].tr('^0-9', '')).order('created_at DESC').first
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
      if a.admin_app?
        admin = true
      end
    end
    admin
  end
end
