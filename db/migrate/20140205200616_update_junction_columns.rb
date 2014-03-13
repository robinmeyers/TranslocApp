class UpdateJunctionColumns < ActiveRecord::Migration
  def change
    add_column :junctions, :b_qstart, :integer
    add_column :junctions, :b_qend, :integer
    add_column :junctions, :b_rname, :string
    add_column :junctions, :b_rstart, :integer
    add_column :junctions, :b_rend, :integer
    add_column :junctions, :b_strand, :string
    rename_column :junctions, :sequence, :seq
    add_column :junctions, :qlen, :integer
    add_column :junctions, :j_seq, :string
  end
end
