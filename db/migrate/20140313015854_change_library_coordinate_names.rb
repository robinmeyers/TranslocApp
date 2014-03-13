class ChangeLibraryCoordinateNames < ActiveRecord::Migration
  def change
    rename_column :libraries, :start, :bstart
    rename_column :libraries, :end, :bend
  end
end
