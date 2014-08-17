class UsersController < ApplicationController

  before_action :authenticate_user!, except: [:new, :new_update]

  def me
    @current_user = current_user
  end

  def new
    if session["devise.new_user_time"] > 30.seconds.ago && session["devise.new_user_id"]
      @user = User.where(confirmed_at: nil, id: session["devise.new_user_id"]).first
      @user.email = @user.unconfirmed_email if @user.email =~ /@dev\.null$/

    else
      flash[:alert] = "session 已過期。"
      redirect_to root_path
    end
  end

  def new_update
    # start hack on devise translate
    I18n.backend.store_translations('zh-TW', {
      devise: {
        mailer: {
          confirmation_instructions: {
            subject: Setting.site_name + " " + I18n.backend.translate('zh-TW', 'devise.mailer.confirmation_instructions.subject')
          },
          reset_password_instructions: {
            subject: Setting.site_name + " " + I18n.backend.translate('zh-TW', 'devise.mailer.reset_password_instructions.subject')
          },
          unlock_instructions: {
            subject: Setting.site_name + " " + I18n.backend.translate('zh-TW', 'devise.mailer.unlock_instructions.subject')
          }
        }
      },
      zhTW_devise_mailer_confirmation_instructions_subject: 'true'
    }) if I18n.translate('zhTW_devise_mailer_confirmation_instructions_subject') != "true"
    # end hack on devise translate

    if session["devise.new_user_id"]
      session["devise.new_user_time"] = Time.now
      @user = User.where(confirmed_at: nil, id: session["devise.new_user_id"]).first
      email = params['user']['email']
      if 1 == 1 # TODO: 確認信箱位址符合 regex
        if @user.update_attribute(:email, email)
          # TODO: 從 email 中抽取出資訊
          # @usersend_confirmation_instructions # this will be done automatically
          flash[:success] = "認證信已送出！"
          redirect_to users_new_path
        else
          flash[:alert] = "認證信發送失敗，請再試一次，若問題持續發生，請聯絡開發者。"
          redirect_to users_new_path
        end
      else
        flash[:alert] = "不合法的 email，請確認你輸入的是正確的學校 email！"
        redirect_to users_new_path
      end

    else
      flash[:alert] = "session 已過期。"
      redirect_to root_path
    end
  end
end
