class Oauth::ApplicationsController < Doorkeeper::ApplicationsController
  before_filter :authenticate_user!
  before_filter :find_application, only: [:show, :edit, :update, :destroy]

  def show
  end

  def index
    if current_user.admin?
      @applications = Doorkeeper::Application.all
    else
      @applications = current_user.oauth_applications
    end
  end

  def create
    @application = Doorkeeper::Application.new(application_params)
    @application.owner = current_user if Doorkeeper.configuration.confirm_application_owner?
    if @application.save
      flash[:notice] = I18n.t(:notice, :scope => [:doorkeeper, :flash, :applications, :create])
      respond_with [:oauth, @application]
    else
      render :new
    end
  end

  def destroy
    flash[:notice] = I18n.t(:notice, :scope => [:doorkeeper, :flash, :applications, :destroy]) if @application.destroy
    redirect_to oauth_applications_url
  end

  private

  def find_application
    if current_user.admin?
      @application = Doorkeeper::Application.find(params[:id])
    else
      @application = current_user.oauth_applications.find(params[:id])
    end
  end
end
