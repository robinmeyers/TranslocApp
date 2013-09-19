class CreateExperiments < ActiveRecord::Migration
  def change
    create_table :experiments do |t|
      t.string :name
      t.integer :researcher_id
      t.integer :sequencing_id

      t.timestamps
    end
    add_index :experiments, [:researcher_id, :sequencing_id]
  end
end
