class UsersController < ApplicationController

  before_action :authenticate_user!

  def me
    @current_user = current_user
  end
end
