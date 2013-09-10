module SessionsHelper
  def sign_in(researcher)
    remember_token = Researcher.new_remember_token
    cookies.permanent[:remember_token] = remember_token
    researcher.update_attribute(:remember_token, Researcher.encrypt(remember_token))
    self.current_researcher = researcher
  end

  def current_researcher=(researcher)
    @current_researcher = researcher
  end

  def current_researcher
    remember_token = Researcher.encrypt(cookies[:remember_token])
    @current_researcher ||= Researcher.find_by(remember_token: remember_token)
  end

  def signed_in?
    !current_researcher.nil?
  end

  def sign_out
    self.current_researcher = nil
    cookies.delete(:remember_token)
  end
end
