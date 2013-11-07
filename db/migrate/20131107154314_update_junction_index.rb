class UpdateJunctionIndex < ActiveRecord::Migration
  def change
    remove_index :junctions, [:rname, :junction, :strand]
    add_index :junctions, [:library_id, :rname, :junction]
  end
end
