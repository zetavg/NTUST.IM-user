class MeController < ApplicationController
  before_action :authenticate_user!, :find_me

  def dashboard
  end

  def information
  end

  def information_update
    faild = false
    if !@user.update(my_params)
      faild = true
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
  end

  private

  def find_me
    @me = User.find(current_user.id)
    @user = User.find(current_user.id)
  end

  def my_params
    params.require(:user).permit(:name, :gender, :department_id, :birthday, :address, :brief)
  end
end
