require 'spec_helper'

describe "Authentication" do

  subject { page }

  describe "signin page" do
    before { visit signin_path }

    it { should have_content('Sign in') }
    it { should have_title('Sign in') }
  end

  describe "signin" do
    before { visit signin_path }

    describe "with invalid information" do
      before { click_button "Sign in" }

      it { should have_title('Sign in') }
      it { should have_selector('div.alert.alert-error', text: 'Invalid') }

      describe "after visiting another page" do
        before { click_link "Home" }
        it { should_not have_selector('div.alert.alert-error') }
      end

    end


    describe "with valid information" do
      let(:researcher) { FactoryGirl.create(:researcher) }
      before do
        fill_in "Email",    with: researcher.email.upcase
        fill_in "Password", with: researcher.password
        click_button "Sign in"
      end

      it { should have_title(researcher.name) }
      it { should have_link('Researchers', href: researchers_path) }
      it { should have_link('Profile',     href: researcher_path(researcher)) }
      it { should have_link('Settings',    href: edit_researcher_path(researcher)) }
      it { should have_link('Sign out',    href: signout_path) }
      it { should_not have_link('Sign in', href: signin_path) }
    end
  end

  describe "authorization" do

    describe "for non-signed-in researchers" do
      let(:researcher) { FactoryGirl.create(:researcher) }


      describe "when attempting to visit a protected page" do
        before do
          visit edit_researcher_path(researcher)
          fill_in "Email",    with: researcher.email
          fill_in "Password", with: researcher.password
          click_button "Sign in"
        end

        describe "after signing in" do

          it "should render the desired protected page" do
            expect(page).to have_title('Edit researcher')
          end
          describe "when signing in again" do
            before do
              delete signout_path
              visit signin_path
              fill_in "Email",    with: researcher.email
              fill_in "Password", with: researcher.password
              click_button "Sign in"
            end

            it "should render the default (profile) page" do
              expect(page).to have_title(researcher.name)
            end
          end
        end
      end

      describe "in the Researchers controller" do

        describe "visiting the edit page" do
          before { visit edit_researcher_path(researcher) }
          it { should have_title('Sign in') }
        end

        describe "submitting to the update action" do
          before { patch researcher_path(researcher) }
          specify { expect(response).to redirect_to(signin_path) }
        end

        describe "visiting the researcher index" do
          before { visit researchers_path }
          it { should have_title('Sign in') }
        end
      end
    end
    describe "as wrong user" do
      let(:researcher) { FactoryGirl.create(:researcher) }
      let(:wrong_researcher) { FactoryGirl.create(:researcher, email: "wrong@example.com") }
      before { sign_in researcher, no_capybara: true }

      describe "submitting a GET request to the Researchers#edit action" do
        before { get edit_researcher_path(wrong_researcher) }
        specify { expect(response.body).not_to match(full_title('Edit researcher')) }
        specify { expect(response).to redirect_to(root_url) }
      end

      describe "submitting a PATCH request to the Researchers#update action" do
        before { patch researcher_path(wrong_researcher) }
        specify { expect(response).to redirect_to(root_url) }
      end
    end

    describe "as non-admin user" do
      let(:researcher) { FactoryGirl.create(:researcher) }
      let(:non_admin) { FactoryGirl.create(:researcher) }

      before { sign_in non_admin, no_capybara: true }

      describe "submitting a DELETE request to the Researchers#destroy action" do
        before { delete researcher_path(researcher) }
        specify { expect(response).to redirect_to(root_url) }
      end
    end
  end
end