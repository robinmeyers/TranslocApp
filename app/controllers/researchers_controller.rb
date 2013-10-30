class ResearchersController < ApplicationController

  before_action :signed_in_researcher, only: [:show, :index, :edit, :update, :destroy]
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
    @libraries = @researcher.libraries.order("id ASC").paginate(page: params[:page])
  end

  def edit
  end

  def update
    if @researcher.update_attributes(researcher_params)
      flash[:success] = "Profile updated"
      unless Settings.adminkey.nil? || @researcher.adminkey.to_s.empty?
        if Digest::SHA1.hexdigest(@researcher.adminkey.to_s) == Settings.adminkey
          @researcher.update_attribute(:admin, true)
          flash[:success] += " - You are now an admin"
        else
          flash[:error] = "Admin Key entered incorrectly"
        end  
      end
      sign_in @researcher
      redirect_to @researcher
    else
      render 'edit'
    end
  end

  def destroy
    @researcher = Researcher.destroy(params[:id])
    flash[:success] = "Researcher #{@researcher.name} destroyed."
    redirect_to researchers_url
  end

  private

    def researcher_params
      params.require(:researcher).permit(:name, :email, :password,
                                   :password_confirmation, :labkey, :adminkey)
    end

    

    def correct_researcher
      @researcher = Researcher.find(params[:id])
      redirect_to(root_url) unless current_researcher?(@researcher)
    end

    def admin_researcher
      redirect_to(root_url) unless current_researcher.admin?
    end



    

end

