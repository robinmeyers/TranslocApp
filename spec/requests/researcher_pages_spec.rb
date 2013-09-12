require 'spec_helper'

describe "Researcher pages" do

  subject { page }

  describe "index" do
    let(:researcher) { FactoryGirl.create(:researcher) }
    before(:each) do
      sign_in researcher
      visit researchers_path
    end

    it { should have_title('All researchers') }
    it { should have_content('All researchers') }

    describe "pagination" do
      before(:all) { 30.times { FactoryGirl.create(:researcher) } }
      after(:all) { Researcher.delete_all }

      it { should have_selector('div.pagination') }

      it "should list each researcher" do
        Researcher.paginate(page: 1).each do |researcher|
          expect(page).to have_selector('li', text: researcher.name)
        end
      end
    end

    describe "delete links" do

      it { should_not have_link('delete') }

      describe "as an admin user" do
        let(:admin) { FactoryGirl.create(:admin) }
        before do
          sign_in admin
          visit researchers_path
        end

        it { should have_link('delete', href: researcher_path(Researcher.first)) }
        it "should be able to delete another user" do
          expect do
            click_link('delete', match: :first)
          end.to change(Researcher, :count).by(-1)
        end
        it { should_not have_link('delete', href: researcher_path(admin)) }
      end
    end
  end


  describe "signup page" do
    describe "without labkey" do
      before do
        Settings.labkey = nil
        visit signup_path
      end

      it { should have_content('Sign up') }
      it { should have_title(full_title('Sign up')) }
      it { should_not have_field('Lab Key') }
    end

    describe "with labkey" do
      before do
        Settings.labkey = Digest::SHA1.hexdigest("barfoo")
        visit signup_path
      end

      it { should have_field('Lab Key') }
    end
  end

  describe "profile page" do
    let(:researcher) { FactoryGirl.create(:researcher) }
    before do
      sign_in researcher
      visit researcher_path(researcher)
    end

    it { should have_content(researcher.name) }
    it { should have_title(researcher.name) }
  end

  describe "signup" do

    let(:submit) { "Create my account" }

    describe "without labkey" do

      before do
        Settings.labkey = nil
        visit signup_path
      end

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
          fill_in "Name",             with: "Example User"
          fill_in "Email",            with: "user@example.com"
          fill_in "Password",         with: "foobar"
          fill_in "Confirm Password", with: "foobar"
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

    describe "with a labkey" do
      before do
        Settings.labkey = Digest::SHA1.hexdigest("barfoo")
        visit signup_path
      end

      describe "with invalid information" do
        before { fill_in "Lab Key", with: "barfoo" }

        it "should not create a researcher" do
          expect { click_button submit }.not_to change(Researcher, :count)
        end
        describe "after submission" do
          before { click_button submit }

          it { should have_title('Sign up') }
          it { should have_content('error') }
        end
      end

      describe "with valid information except for labkey" do
        before do
          fill_in "Name",             with: "Example User"
          fill_in "Email",            with: "user@example.com"
          fill_in "Password",         with: "foobar"
          fill_in "Confirm Password", with: "foobar"
        end
        it "should not create a researcher" do
          expect { click_button submit }.not_to change(Researcher, :count)
        end
        describe "after submission" do
          before { click_button submit }

          it { should have_title('Sign up') }
          it { should have_selector('div.alert.alert-error', text: 'Lab Key') }
        end
      end

      describe "with valid information" do
        before do
          fill_in "Name",             with: "Example User"
          fill_in "Email",            with: "user@example.com"
          fill_in "Password",         with: "foobar"
          fill_in "Confirm Password", with: "foobar"
          fill_in "Lab Key",          with: "barfoo"
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

    describe "forbidden attributes" do
      let(:params) do
        { researcher: { admin: true, password: researcher.password,
                  password_confirmation: researcher.password } }
      end
      before do
        sign_in researcher, no_capybara: true
        patch researcher_path(researcher), params
      end
      specify { expect(researcher.reload).not_to be_admin }
    end
  end
end
