class AddLibraryIdToJunctions < ActiveRecord::Migration
  def change
    add_column :junctions, :library_id, :integer
  end
end
