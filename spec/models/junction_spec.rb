require 'spec_helper'

describe Junction do

  let(:library) { FactoryGirl.create(:library) }
  before do
    # This code is not idiomatically correct.
    @junction = Junction.new(rname: "15", library_id: library.id)
  end

  subject { @junction }

  it { should respond_to(:rname) }
  it { should respond_to(:library_id) }
end