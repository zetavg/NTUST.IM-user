class Api::V1::OauthApiController < ApplicationController
  doorkeeper_for :all
  respond_to     :json
  protect_from_forgery

  swagger_controller :users, "OAuth 2.0 User 相關 API"

  swagger_api :me do
    summary "取得使用者資料"
    notes "透過 access token 取得其擁有者的基本資料。"
    param :query, :access_token, :string, :required, "access token"
    response :unauthorized
  end

  def me
    respond_with current_resource_owner
  end

  private

  def current_resource_owner
    User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
  end
end
