class ResearchersController < ApplicationController

  before_action :signed_in_researcher, only: [:index, :edit, :update, :destroy]
  before_action :correct_researcher,   only: [:edit, :update]
  before_action :admin_researcher,     only: :destroy

  def new
    @researcher = Researcher.new
  end

  def index
    @researchers = Researcher.paginate(page: params[:page])
  end

  def create
    @researcher = Researcher.new(researcher_params)
    if Settings.labkey.nil? || Digest::SHA1.hexdigest(@researcher.labkey.to_s) == Settings.labkey
      if @researcher.save
        sign_in @researcher
        flash[:success] = "Welcome to the Transloc App!"
        redirect_to @researcher
      else
        render 'new'
      end
    else
      flash.now[:error] = "Lab Key was not entered correctly"
      render 'new'
    end
  end



  def show
    @researcher = Researcher.find(params[:id])
  end

  def edit
  end

  def update
    if @researcher.update_attributes(researcher_params)
      flash[:success] = "Profile updated"
      sign_in @researcher
      redirect_to @researcher
    else
      render 'edit'
    end
  end

  def destroy
    Researcher.find(params[:id]).destroy
    flash[:success] = "Researcher destroyed."
    redirect_to researchers_url
  end

  private

    def researcher_params
      params.require(:researcher).permit(:name, :email, :password,
                                   :password_confirmation, :labkey)
    end

    def signed_in_researcher
      unless signed_in?
        store_location
        redirect_to signin_url, notice: "Please sign in."
      end
    end

    def correct_researcher
      @researcher = Researcher.find(params[:id])
      redirect_to(root_url) unless current_researcher?(@researcher)
    end

    def admin_researcher
      redirect_to(root_url) unless current_researcher.admin?
    end



    

end

