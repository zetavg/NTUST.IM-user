class MeController < ApplicationController
  before_action :authenticate_user!

  def dashboard
  end

  def information
  end

  def notifications
  end

  def friends
  end

  def settings
  end
end
