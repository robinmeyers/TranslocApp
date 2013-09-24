require 'spec_helper'

describe Researcher do

  before do
    @researcher = Researcher.new(name: "Example Researcher", email: "researcher@example.com",
                     password: "foobar", password_confirmation: "foobar")
  end

  subject { @researcher }

  it { should respond_to(:name) }
  it { should respond_to(:email) }
  it { should respond_to(:password_digest)}
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }
  it { should respond_to(:remember_token) }
  it { should respond_to(:authenticate) }
  it { should respond_to(:admin) }
  it { should respond_to(:experiments) }

  it { should be_valid }
  it { should_not be_admin }

  describe "with admin attribute set to 'true'" do
    before do
      @researcher.save!
      @researcher.toggle!(:admin)
    end

    it { should be_admin }
  end

  describe "when name is not present" do
    before { @researcher.name = " " }
    it { should_not be_valid }
  end

  describe "when email is not present" do
    before { @researcher.email = " " }
    it { should_not be_valid }
  end

  describe "when name is too long" do
    before { @researcher.name = "a" * 51 }
    it { should_not be_valid }
  end

  describe "when email format is invalid" do
    it "should be invalid" do
      addresses = %w[user@foo,com user_at_foo.org example.user@foo.
                     foo@bar_baz.com foo@bar+baz.com]
      addresses.each do |invalid_address|
        @researcher.email = invalid_address
        expect(@researcher).not_to be_valid
      end
    end
  end

  describe "when email format is valid" do
    it "should be valid" do
      addresses = %w[user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
      addresses.each do |valid_address|
        @researcher.email = valid_address
        expect(@researcher).to be_valid
      end
    end
  end

  describe "when email address is already taken" do
    before do
      researcher_with_same_email = @researcher.dup
      researcher_with_same_email.email = @researcher.email.upcase
      researcher_with_same_email.save
    end

    it { should_not be_valid }
  end

  describe "email address with mixed case" do
    let(:mixed_case_email) { "Foo@ExAMPle.CoM" }

    it "should be saved as all lower-case" do
      @researcher.email = mixed_case_email
      @researcher.save
      expect(@researcher.reload.email).to eq mixed_case_email.downcase
    end
  end

  describe "when password is not present" do
    before do
      @researcher = Researcher.new(name: "Example User", email: "user@example.com",
                       password: " ", password_confirmation: " ")
    end
    it { should_not be_valid }
  end

  describe "when password doesn't match confirmation" do
    before { @researcher.password_confirmation = "mismatch" }
    it { should_not be_valid }
  end

  describe "with a password that's too short" do
    before { @researcher.password = @researcher.password_confirmation = "a" * 5 }
    it { should be_invalid }
  end

  describe "return value of authenticate method" do
    before { @researcher.save }
    let(:found_researcher) { Researcher.find_by(email: @researcher.email) }

    describe "with valid password" do
      it { should eq found_researcher.authenticate(@researcher.password) }
    end

    describe "with invalid password" do
      let(:researcher_for_invalid_password) { found_researcher.authenticate("invalid") }

      it { should_not eq researcher_for_invalid_password }
      specify { expect(researcher_for_invalid_password).to be_false }
    end
  end

  describe "remember token" do
    before { @researcher.save }
    its(:remember_token) { should_not be_blank }
  end

  describe "experiment associations" do

    before do
      @researcher.save
      @old_sequencing = FactoryGirl.create(:completed_sequencing)
      @new_sequencing = FactoryGirl.create(:completed_sequencing)
    end
    let!(:older_experiment) do
      FactoryGirl.create(:experiment, researcher: @researcher, sequencing: @old_sequencing)
    end
    let!(:newer_experiment) do
      FactoryGirl.create(:experiment, researcher: @researcher, sequencing: @new_sequencing)
    end

    it "should have the right experiments in the right order" do
      expect(@researcher.experiments.to_a).to eq [newer_experiment, older_experiment]
    end
  end

end