require 'spec_helper'

describe Library do

  let(:researcher) { FactoryGirl.create(:researcher) }
  let(:sequencing) { FactoryGirl.create(:sequencing) }
  before do
    @library = FactoryGirl.create(:library, researcher: researcher, sequencing: sequencing)
  end

  subject { @library }

  it { should respond_to(:name) }
  it { should respond_to(:researcher_id) }
  it { should respond_to(:sequencing_id) }
  it { should respond_to(:researcher) }
  it { should respond_to(:sequencing) }
  it { should respond_to(:junctions) }
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

  describe "junction associations" do

    before { @library.save }
    let!(:junction) do
      FactoryGirl.create(:junction, library: @library)
    end
    it "should destroy associated junctions" do
      junctions = @library.junctions.to_a
      @library.destroy
      expect(junctions).not_to be_empty
      junctions.each do |junction|
        expect(Junction.where(id: junction.id)).to be_empty
      end
    end
  end

end