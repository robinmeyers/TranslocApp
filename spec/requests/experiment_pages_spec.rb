require 'spec_helper'

describe "Experiment pages" do

  subject { page }

  let(:researcher) { FactoryGirl.create(:researcher) }
  let(:sequencing) { FactoryGirl.create(:completed_sequencing) }
  before { sign_in researcher }

  describe "experiment creation" do
    before { visit sequencing_path(sequencing) }

    describe "with invalid information" do

      it "should not create an experiment" do
        expect { click_button "Create Experiment" }.not_to change(Experiment, :count)
      end

      describe "error messages" do
        before { click_button "Create Experiment" }
        it { should have_content('error') }
      end
    end

    describe "with valid information" do

      before { fill_in 'experiment_name', with: "Exp001" }
      it "should create a experiment" do
        expect { click_button "Create Experiment" }.to change(Experiment, :count).by(1)
      end
    end
  end
end
