class ResearchersController < ApplicationController
  def new
    @researcher = Researcher.new
  end

  def create
    @researcher = Researcher.new(researcher_params)
    if @researcher.save
      flash[:success] = "Welcome to the Transloc App!"
      redirect_to @researcher
    else
      render 'new'
    end
  end

  def show
    @researcher = Researcher.find(params[:id])
  end

  private

    def researcher_params
      params.require(:researcher).permit(:name, :email, :password,
                                   :password_confirmation)
    end

end

