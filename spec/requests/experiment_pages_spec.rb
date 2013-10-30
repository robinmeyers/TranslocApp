require 'spec_helper'

describe "Library pages" do

  subject { page }

  let(:researcher) { FactoryGirl.create(:researcher) }
  let(:sequencing) { FactoryGirl.create(:completed_sequencing) }
  before { sign_in researcher }

  describe "library creation" do
    before { visit sequencing_path(sequencing) }

    describe "with invalid information" do

      it "should not create an library" do
        expect { click_button "Create Library" }.not_to change(Library, :count)
      end

      describe "error messages" do
        before { click_button "Create Library" }
        it { should have_content('error') }
      end
    end

    describe "with valid information" do

      before { fill_in 'library_name', with: "Exp001" }
      it "should create a library" do
        expect { click_button "Create Library" }.to change(Library, :count).by(1)
      end
    end
  end
end
