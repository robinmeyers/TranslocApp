require 'spec_helper'

describe Junction do

  let(:library) { FactoryGirl.create(:library) }

  before { @junction = library.junctions.build(rname: "15") }
  


  subject { @junction }

  it { should respond_to(:rname) }
  it { should respond_to(:library_id) }
  it { should respond_to(:library) }

  describe "when library_id is not present" do
    before { @junction.library_id = nil }
    it { should_not be_valid }
  end

end