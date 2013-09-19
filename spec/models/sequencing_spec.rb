require 'spec_helper'

describe Sequencing do
  before { @sequencing = Sequencing.new(run: "Sample Run") }

  subject { @sequencing }

  it { should respond_to(:run) }
  it { should respond_to(:experiments) }
  it { should be_valid }

  describe "when run is not present" do
    before  { @sequencing.run = nil }
    it { should_not be_valid }
  end

  describe "when run is already taken" do
    before do
      sequencing_with_same_run = @sequencing.dup
      sequencing_with_same_run.run = sequencing_with_same_run.run.upcase
      sequencing_with_same_run.save
    end

    it { should_not be_valid }
  end
end