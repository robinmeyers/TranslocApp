class ResearchersController < ApplicationController

  before_action :signed_in_researcher, only: [:edit, :update]
  before_action :correct_researcher,   only: [:edit, :update]

  def new
    @researcher = Researcher.new
  end

  def create
    @researcher = Researcher.new(researcher_params)
    if @researcher.save
      sign_in @researcher
      flash[:success] = "Welcome to the Transloc App!"
      redirect_to @researcher
    else
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

  private

    def researcher_params
      params.require(:researcher).permit(:name, :email, :password,
                                   :password_confirmation)
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

end

