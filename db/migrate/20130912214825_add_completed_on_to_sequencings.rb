class AddCompletedOnToSequencings < ActiveRecord::Migration
  def change
    add_column :sequencings, :completed_on, :date
    remove_index :sequencings, [:run, :created_at]
    add_index :sequencings, [:run, :completed_on]
  end
end
