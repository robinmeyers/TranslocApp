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
    end
  end
end
