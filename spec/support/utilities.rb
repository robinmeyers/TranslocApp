include ApplicationHelper

def sign_in(researcher, options={})
  if options[:no_capybara]
    # Sign in when not using Capybara.
    remember_token = Researcher.new_remember_token
    cookies[:remember_token] = remember_token
    researcher.update_attribute(:remember_token, Researcher.encrypt(remember_token))
  else
    visit signin_path
    fill_in "Email",    with: researcher.email
    fill_in "Password", with: researcher.password
    click_button "Sign in"
  end
end