# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Assembly.delete_all
Chromosome.delete_all
Cytoband.delete_all

require 'csv'
["mm9","hg19"].each do |genome|

  assembly = Assembly.create!(name: genome)

  chr_opts = {headers: [:name, :size], col_sep: "\t"}
  chr_file = Rails.root.join('data', 'assembly', genome, 'ChromInfo.txt')

  CSV.foreach(chr_file, chr_opts) do |row|
    assembly.chromosomes.create!(name: row[:name], size: row[:size])
  end


  cyto_file = Rails.root.join('data', 'assembly', genome, 'cytoBand.txt')
  cyto_opts = {headers: [:chrom, :start, :end, :name, :stain], col_sep: "\t"}

  CSV.foreach(cyto_file, cyto_opts) do |row|
    assembly.cytobands.create!( name: row[:name],
                                chrom: row[:chrom],
                                start: row[:start],
                                end: row[:end],
                                stain: row[:stain] )
  end


end