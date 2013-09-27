class ChangeBrkstrandFromBooleanToString < ActiveRecord::Migration
  def change
    remove_column :experiments, :brkstrand
    add_column :experiments, :brkstrand, :string
  end
end
