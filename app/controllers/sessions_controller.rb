class SessionsController < ApplicationController

  def new
  end

  def create
    researcher = Researcher.find_by(email: params[:session][:email].downcase)
    if researcher && researcher.authenticate(params[:session][:password])
      sign_in researcher
      redirect_back_or researcher
    else
      flash.now[:error] = 'Invalid email/password combination' # Not quite right!
      render 'new'
    end
  end

  def destroy
    sign_out
    redirect_to root_url
  end


end
