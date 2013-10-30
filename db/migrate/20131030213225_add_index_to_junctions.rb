class AddIndexToJunctions < ActiveRecord::Migration
  def change
    add_column :junctions, :junction, :integer

    add_index :junctions, [:rname, :junction, :strand]
  end
end
