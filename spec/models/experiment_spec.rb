require 'spec_helper'

describe Experiment do

  let(:researcher) { FactoryGirl.create(:researcher) }
  let(:sequencing) { FactoryGirl.create(:sequencing) }
  before do
    @experiment = researcher.experiments.build(name: "Exp001", sequencing_id: sequencing.id)
  end

  subject { @experiment }

  it { should respond_to(:name) }
  it { should respond_to(:researcher_id) }
  it { should respond_to(:sequencing_id) }
  it { should respond_to(:researcher) }
  it { should respond_to(:sequencing) }
  its(:researcher) { should eq researcher }
  its(:sequencing) { should eq sequencing }

  it { should be_valid }

  describe "when researcher_id is not present" do
    before { @experiment.researcher_id = nil }
    it { should_not be_valid }
  end

  describe "when sequencing_id is not present" do
    before { @experiment.sequencing_id = nil }
    it { should_not be_valid}
  end

end