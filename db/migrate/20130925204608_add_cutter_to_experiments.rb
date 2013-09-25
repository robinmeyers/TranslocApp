class AddCutterToExperiments < ActiveRecord::Migration
  def change
    add_column :experiments, :cutter, :string
  end
end
