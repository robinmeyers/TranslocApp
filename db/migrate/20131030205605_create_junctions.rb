class CreateJunctions < ActiveRecord::Migration
  def change
    create_table :junctions do |t|
      t.string :qname
      t.integer :qstart
      t.integer :qend
      t.string :rname
      t.integer :rstart
      t.integer :rend
      t.string :strand
      t.text :sequence

      t.timestamps
    end
  end
end
