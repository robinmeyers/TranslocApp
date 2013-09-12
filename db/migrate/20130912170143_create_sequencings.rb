class CreateSequencings < ActiveRecord::Migration
  def change
    create_table :sequencings do |t|
      t.string :run

      t.timestamps
    end
    add_index :sequencings, [:run, :created_at]
  end
end
