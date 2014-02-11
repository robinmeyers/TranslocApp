class UpdateLibraryColumns < ActiveRecord::Migration
  def change
    rename_column :libraries, :breaksite, :breakseq
    add_column :libraries, :breaksite, :integer
    rename_column :libraries, :brkchr, :chr
    rename_column :libraries, :brkstart, :start
    rename_column :libraries, :brkend, :end
    rename_column :libraries, :brkstrand, :strand
  end
end
