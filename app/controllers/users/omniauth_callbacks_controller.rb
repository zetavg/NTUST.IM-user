class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def facebook
    @user = User.from_facebook(request.env["omniauth.auth"])
    if @user.confirmed?
      set_flash_message(:notice, :success, :kind => "Facebook") if is_navigational_format?
      sign_in_and_redirect @user
    else
      session["devise.new_user_time"] = Time.now
      session["devise.new_user_id"] = @user.id
      redirect_to users_new_path
    end
  end
end
