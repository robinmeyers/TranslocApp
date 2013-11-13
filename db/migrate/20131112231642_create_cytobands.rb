class CreateCytobands < ActiveRecord::Migration
  def change
    create_table :cytobands do |t|
      t.string :name
      t.integer :assembly_id
      t.string :chrom
      t.integer :start
      t.integer :end
      t.string :stain

      t.timestamps
    end
  end
end
