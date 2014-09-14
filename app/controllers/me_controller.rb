class MeController < ApplicationController
  before_action :authenticate_user!, :find_me

  def dashboard
  end

  def information
  end

  def information_update
    t = Time.now.to_i.to_s
    cookies[:login_update_time] = { value: t, domain: '.' + Setting.app_domain }

    faild = false

    if !@user.update(my_params)
      faild = true
    end

    ActiveRecord::Base.transaction do
      if params['commit'] == "confirm_mobile" || (params['mobile_confirm_token'] != '' && params['mobile_confirm_token'] != nil)
        confirm_mobile(params['mobile_confirm_token'])
      elsif params['commit'] == "reconfirm_mobile"
        send_confirmation_sms
      elsif params[:mobile].to_s != '' && params[:mobile] != @user.mobile && params[:mobile] != @user.unconfirmed_mobile
        current_user.unconfirmed_mobile = params[:mobile].tr('^0-9', '').gsub(/^09/, '8869').gsub(/^88609/, '8869')
        current_user.mobile = nil
        current_user.save
        send_confirmation_sms
      elsif params[:mobile].to_s == ''
        current_user.mobile = nil
        current_user.unconfirmed_mobile = nil
        current_user.save
      end
    end

    if faild
      flash[:alert] = '儲存失敗。'
      render :information
    else
      flash[:success] = '儲存成功。'
      redirect_to information_path
    end
  end

  def notifications
  end

  def friends
  end

  def settings
    @settings = current_user.settings.get_all
  end

  def settings_update
    t = Time.now.to_i.to_s
    cookies[:login_update_time] = { value: t, domain: '.' + Setting.app_domain }

    if params['display_fixed_top_bar'].to_s == 'yes'
      current_user.settings['display_not_fixed_top_bar'] = false
    else
      current_user.settings['display_not_fixed_top_bar'] = true
    end

    flash[:notice] = '設定已儲存。'
    redirect_to settings_path
  end

  private

  def find_me
    @me = User.find(current_user.id)
    @user = User.find(current_user.id)
  end

  def my_params
    params.require(:user).permit(:name, :gender, :department_code, :birthday, :address, :brief)
  end

  def send_confirmation_sms
    success = true
    current_user.mobile_confirmation_token = 10000 + Random.rand(89999)
    current_user.mobile_confirm_tries += 1
    current_user.mobile_confirmation_sent_at = Time.now
    current_user.save
    success = false if current_user.mobile_confirm_tries > 16
    if success
      nexmo = Nexmo::Client.new(key: Setting.nexmo_key, secret: Setting.nexmo_secret)
      success = nexmo.send_message(from: Setting.site_name, to: current_user.unconfirmed_mobile.tr('^0-9', ''), type: "unicode", text: "歡迎登入 #{Setting.site_name}，您的手機驗證碼是 #{current_user.mobile_confirmation_token}。")
    end
    if success
      flash[:info] = '驗證簡訊已送出。'
    else
      flash[:info] = '驗證簡訊傳送失敗。您可能嘗試太多次了。若問題持續發生請洽管理員。'
    end
  end

  def confirm_mobile(token)
    if (Time.now - current_user.mobile_confirmation_sent_at) > 43200
      flash[:info] = '驗證碼已失效。請重寄驗證簡訊。'
      return false
    elsif token == current_user.mobile_confirmation_token
      current_user.mobile = current_user.unconfirmed_mobile
      current_user.unconfirmed_mobile = nil
      current_user.save
      flash[:info] = '手機號碼驗證成功。'
      return true
    else
      flash[:info] = '驗證碼不正確。'
      return false
    end
  end
end
