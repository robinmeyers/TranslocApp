class RenameExperimentsToLibraries < ActiveRecord::Migration
  def change
    rename_table :experiments, :libraries
  end
end
