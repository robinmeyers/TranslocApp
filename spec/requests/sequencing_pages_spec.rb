require 'spec_helper'

describe "Sequencing pages" do
  subject { page }
  let(:researcher) { FactoryGirl.create(:researcher) }
  before { sign_in researcher }

  describe "index page" do

    before { visit sequencings_path }

    it { should have_title('Sequencings') }
    it { should have_content('Sequencing Runs') }

    describe "pagination" do
      before(:all) { 30.times { FactoryGirl.create(:completed_sequencing) } }
      after(:all) { Sequencing.delete_all }

      it { should have_selector('div.pagination') }

      it "should list each sequencing" do
        Sequencing.paginate(page: 1).each do |sequencing|
          expect(page).to have_selector('li', text: sequencing.run)
        end
      end
    end
  end


  describe "uncompleted sequencing run page" do
    let(:sequencing) { FactoryGirl.create(:sequencing) }
    before { visit sequencing_path(sequencing) }

    it { should have_title(sequencing.run) }
    it { should have_content(sequencing.run) }
    it { should have_content("Uncompleted") }
  end

end

    # describe "delete links" do

    #   it { should_not have_link('delete') }

    #   describe "as an admin user" do
    #     let(:admin) { FactoryGirl.create(:admin) }
    #     before do
    #       sign_in admin
    #       visit researchers_path
    #     end

    #     it { should have_link('delete', href: researcher_path(Researcher.first)) }
    #     it "should be able to delete another user" do
    #       expect do
    #         click_link('delete', match: :first)
    #       end.to change(Researcher, :count).by(-1)
    #     end
    #     it { should_not have_link('delete', href: researcher_path(admin)) }
    #   end
    # end
#   end

# end
