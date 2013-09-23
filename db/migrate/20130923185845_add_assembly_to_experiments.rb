class AddAssemblyToExperiments < ActiveRecord::Migration
  def change
    add_column :experiments, :assembly, :string
    add_column :experiments, :mid, :string
    add_column :experiments, :primer, :string
    add_column :experiments, :breaksite, :text
    add_column :experiments, :adapter, :string
    add_column :experiments, :brkchr, :string
    add_column :experiments, :brkstart, :integer
    add_column :experiments, :brkend, :integer
    add_column :experiments, :description, :text
  end
end
