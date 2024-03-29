Doorkeeper.configure do
  # Change the ORM that doorkeeper will use.
  # Currently supported options are :active_record, :mongoid2, :mongoid3, :mongo_mapper
  orm :active_record

  # This block will be called to check whether the resource owner is authenticated or not.
  resource_owner_authenticator do
    # fail "Please configure doorkeeper resource_owner_authenticator block located in #{__FILE__}"
    # Put your resource owner authentication logic here.
    # Example implementation:
    #   User.find_by_id(session[:user_id]) || redirect_to(new_user_session_url)
    if current_user
      t = Time.now.to_i.to_s
      cookies[:login_token_gtime] = { value: t, domain: '.' + Setting.app_domain }
      cookies[:login_token] = { value: Digest::MD5.hexdigest(Setting.site_secret_key + t + current_user.id.to_s), domain: '.' + Setting.app_domain }
    else
      cookies[:login_token] = { value: '', domain: '.' + Setting.app_domain }
    end
    (current_user && User.confirmed.find(current_user.id)) || warden.authenticate!(:scope => :user)
  end

  # If you want to restrict access to the web interface for adding oauth authorized applications, you need to declare the block below.
  admin_authenticator do
    # Put your admin authentication logic here.
    # Example implementation:
    # Admin.find_by_id(session[:admin_id]) || redirect_to(new_admin_session_url)
    (current_user && User.find_by_id(current_user.id)) || (current_admin && Admin.find_by_id(current_admin.id)) || redirect_to(root_path)
    # User.where(["admin = ?", true]).find_by_id(current_user.id) || redirect_to(root_path)
  end

  # Authorization Code expiration time (default 10 minutes).
  # authorization_code_expires_in 10.minutes

  # Access token expiration time (default 2 hours).
  # If you want to disable expiration, set this to nil.
  # access_token_expires_in 2.hours

  # Reuse access token for the same resource owner within an application (disabled by default)
  # Rationale: https://github.com/doorkeeper-gem/doorkeeper/issues/383
  # reuse_access_token

  # Issue access tokens with refresh token (disabled by default)
  # use_refresh_token

  # Provide support for an owner to be assigned to each registered application (disabled by default)
  # Optional parameter :confirmation => true (default false) if you want to enforce ownership of
  # a registered application
  # Note: you must also run the rails g doorkeeper:application_owner generator to provide the necessary support
  enable_application_owner :confirmation => true

  # Define access token scopes for your provider
  # For more information go to
  # https://github.com/doorkeeper-gem/doorkeeper/wiki/Using-Scopes
  default_scopes  :public
  optional_scopes :email, :school, :facebook, :friends, :notification, :profile, :sms, :offline_access, :admin

  # Change the way client credentials are retrieved from the request object.
  # By default it retrieves first from the `HTTP_AUTHORIZATION` header, then
  # falls back to the `:client_id` and `:client_secret` params from the `params` object.
  # Check out the wiki for more information on customization
  # client_credentials :from_basic, :from_params

  # Change the way access token is authenticated from the request object.
  # By default it retrieves first from the `HTTP_AUTHORIZATION` header, then
  # falls back to the `:access_token` or `:bearer_token` params from the `params` object.
  # Check out the wiki for more information on customization
  # access_token_methods :from_bearer_authorization, :from_access_token_param, :from_bearer_param

  # Change the native redirect uri for client apps
  # When clients register with the following redirect uri, they won't be redirected to any server and the authorization code will be displayed within the provider
  # The value can be any string. Use nil to disable this feature. When disabled, clients must provide a valid URL
  # (Similar behaviour: https://developers.google.com/accounts/docs/OAuth2InstalledApp#choosingredirecturi)
  #
  # native_redirect_uri 'urn:ietf:wg:oauth:2.0:oob'

  # Specify what grant flows are enabled in array of Strings. The valid
  # strings and the flows they enable are:
  #
  # "authorization_code" => Authorization Code Grant Flow
  # "implicit"           => Implicit Grant Flow
  # "password"           => Resource Owner Password Credentials Grant Flow
  # "client_credentials" => Client Credentials Grant Flow
  #
  # If not specified, Doorkeeper enables all the four grant flows.
  #
  # grant_flows %w(authorization_code implicit password client_credentials)

  # Under some circumstances you might want to have applications auto-approved,
  # so that the user skips the authorization step.
  # For example if dealing with trusted a application.
  # skip_authorization do |resource_owner, client|
  #   client.superapp? or resource_owner.admin?
  # end
  skip_authorization do |resource_owner, client|
    client.application.admin_app?
  end

  # WWW-Authenticate Realm (default "Doorkeeper").
  realm Setting.app_name

  # Allow dynamic query parameters (disabled by default)
  # Some applications require dynamic query parameters on their request_uri
  # set to true if you want this to be allowed
  wildcard_redirect_uri true
end

class Doorkeeper::Application < ActiveRecord::Base
  scope :user_apps, -> { where("owner_type = ?", 'User') }
  scope :admin_apps, -> { where("owner_type = ?", 'Admin') }

  has_one :data, class_name: "OauthApplicationData", foreign_key: "application_id"

  def admin_app?
    # (!!owner && owner_type == 'User' && owner.admin?) || owner_type == 'Admin'
    owner_type == 'Admin'
  end
end
