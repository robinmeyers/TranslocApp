class CreateChromosomes < ActiveRecord::Migration
  def change
    create_table :chromosomes do |t|
      t.string :name
      t.integer :assembly_id
      t.integer :size

      t.timestamps
    end
  end
end
