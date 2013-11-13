namespace :db do
  desc "Fill database with assembly data"
  task assembly_data: :environment do

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
                                    stain: row[:end] )
      end


    end
  end
end