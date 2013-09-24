class AddBrkstrandToExperiments < ActiveRecord::Migration
  def change
    add_column :experiments, :brkstrand, :boolean
  end
end
