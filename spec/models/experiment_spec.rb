require 'spec_helper'

describe Library do

  let(:researcher) { FactoryGirl.create(:researcher) }
  let(:sequencing) { FactoryGirl.create(:sequencing) }
  before do
    @library = researcher.libraries.build(name: "Exp001", sequencing_id: sequencing.id)
  end

  subject { @library }

  it { should respond_to(:name) }
  it { should respond_to(:researcher_id) }
  it { should respond_to(:sequencing_id) }
  it { should respond_to(:researcher) }
  it { should respond_to(:sequencing) }
  its(:researcher) { should eq researcher }
  its(:sequencing) { should eq sequencing }

  it { should be_valid }

  describe "when researcher_id is not present" do
    before { @library.researcher_id = nil }
    it { should_not be_valid }
  end

  describe "when sequencing_id is not present" do
    before { @library.sequencing_id = nil }
    it { should_not be_valid}
  end

end