require 'spec_helper'

describe "Library pages" do

  subject { page }

  let(:researcher) { FactoryGirl.create(:researcher) }
  let(:sequencing) { FactoryGirl.create(:completed_sequencing) }
  before { sign_in researcher }

  describe "library page" do
    let(:library) { FactoryGirl.create(:library, researcher: researcher, sequencing: sequencing) }
    let!(:j1) { FactoryGirl.create(:junction, library: library, rname: "chr12") }
    let!(:j2) { FactoryGirl.create(:junction, library: library, rname: "chr15") }

    before { visit library_path(library) }

    it { should have_content(library.name) }
    it { should have_title(library.name) }

    describe "junctions" do
      it { should have_content(j1.rname) }
      it { should have_content(j2.rname) }
      it { should have_content(library.junctions.count) }
    end
  end

  describe "library creation" do
    before { visit new_library_path(sequencing_id: sequencing.id) }

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

      before do
        fill_in 'library_name', with: "Lib001"
        fill_in 'library_mid', with: "ACGT"
        fill_in 'library_cutter', with: "TTAA"
        fill_in 'library_primer', with: "ACGTACGTACGT"
        fill_in 'library_adapter', with: "ACGTACGT"
        select 'mm9', from: 'library_assembly'
        fill_in 'library_chr', with: "15"
        fill_in 'library_bstart', with: 1000000
        fill_in 'library_bend', with: 1000001
        select '+', from: 'library_strand'

      end

      it "should create a library" do
        expect { click_button "Create Library" }.to change(Library, :count).by(1)
      end
    end
  end
end
