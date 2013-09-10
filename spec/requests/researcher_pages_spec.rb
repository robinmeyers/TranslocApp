require 'spec_helper'

describe "Researcher pages" do

  subject { page }

  describe "signup page" do
    before { visit signup_path }

    it { should have_content('Sign up') }
    it { should have_title(full_title('Sign up')) }
  end

  describe "profile page" do
    let(:researcher) { FactoryGirl.create(:researcher) }
    before { visit researcher_path(researcher) }

    it { should have_content(researcher.name) }
    it { should have_title(researcher.name) }
  end

  describe "signup" do

    before { visit signup_path }

    let(:submit) { "Create my account" }

    describe "with invalid information" do
      it "should not create a researcher" do
        expect { click_button submit }.not_to change(Researcher, :count)
      end
      describe "after submission" do
        before { click_button submit }

        it { should have_title('Sign up') }
        it { should have_content('error') }
      end
    end

    describe "with valid information" do
      before do
        fill_in "Name",         with: "Example User"
        fill_in "Email",        with: "user@example.com"
        fill_in "Password",     with: "foobar"
        fill_in "Confirmation", with: "foobar"
      end

      it "should create a researcher" do
        expect { click_button submit }.to change(Researcher, :count).by(1)
      end

      describe "after saving the researcher" do
        before { click_button submit }
        let(:researcher) { Researcher.find_by(email: 'user@example.com') }
        it { should have_link('Sign out') }
        it { should have_title(researcher.name) }
        it { should have_selector('div.alert.alert-success', text: 'Welcome') }

        describe "followed by signout" do
          before { click_link "Sign out" }
          it { should have_link('Sign in') }
        end
      end
      
    end
  end

  describe "edit" do
    let(:researcher) { FactoryGirl.create(:researcher) }
    before do
      sign_in researcher
      visit edit_researcher_path(researcher)
    end

    describe "page" do
      it { should have_content("Update your profile") }
      it { should have_title("Edit researcher") }
      it { should have_link('change', href: 'http://gravatar.com/emails') }
    end

    describe "with invalid information" do
      before { click_button "Save changes" }

      it { should have_content('error') }
    end

    describe "with valid information" do
      let(:new_name)  { "New Name" }
      let(:new_email) { "new@example.com" }
      before do
        fill_in "Name",             with: new_name
        fill_in "Email",            with: new_email
        fill_in "Password",         with: researcher.password
        fill_in "Confirm Password", with: researcher.password
        click_button "Save changes"
      end

      it { should have_title(new_name) }
      it { should have_selector('div.alert.alert-success') }
      it { should have_link('Sign out', href: signout_path) }
      specify { expect(researcher.reload.name).to  eq new_name }
      specify { expect(researcher.reload.email).to eq new_email }
    end
  end
end
