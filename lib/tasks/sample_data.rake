namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do

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

    Researcher.create!(name: "Robin Meyers",
                 email: "robin.m.meyers@gmail.com",
                 password: "foobar",
                 password_confirmation: "foobar",
                 admin: true)
    Researcher.create!(name: "Example User",
                 email: "example@railstutorial.org",
                 password: "foobar",
                 password_confirmation: "foobar")
    25.times do |n|
      name  = Faker::Name.name
      email = "example-#{n+1}@railstutorial.org"
      password  = "password"
      Researcher.create!(name: name,
                   email: email,
                   password: password,
                   password_confirmation: password)
  
    end
    (35..50).each do |n|
      run = "Alt%03d" % n
      completed_on = (50-n).weeks.ago
      Sequencing.create!(run: run, completed_on: completed_on)
    end

    

    Researcher.first(4).each do |researcher|
      sequencing_offset = 0
      (1..2).to_a.reverse.each do |n|
        sequencing_offset += rand(3)
        sequencing = Sequencing.offset(sequencing_offset).first
        name = researcher.name.scan(/[A-Z]/).join + "%03d" % n
        description = Faker::Lorem.sentence(5)
        assembly = ["mm9","hg19"].sample
        brkchr = "chr" + ((1..22).to_a + ["X","Y"]).sample.to_s
        brkstart = rand(100000000)
        brkend = brkstart + rand(500)
        brkstrand = ["+","-"].sample
        mid = ["A","C","G","T"].values_at(*Array.new(rand(10)){rand(4)}).join
        primer = ["A","C","G","T"].values_at(*Array.new(rand(10)+15){rand(4)}).join
        adapter = ["A","C","G","T"].values_at(*Array.new(rand(10)+15){rand(4)}).join
        breaksite = ["A","C","G","T"].values_at(*Array.new(rand(300)+200){rand(4)}).join
        cutter = ["AGCT","GGAA",""].sample
        library = researcher.libraries.create!(sequencing: sequencing,
                                       name: name,
                                       description: description,
                                       assembly: assembly,
                                       brkchr: brkchr,
                                       brkstart: brkstart,
                                       brkend: brkend,
                                       brkstrand: brkstrand,
                                       mid: mid,
                                       primer: primer,
                                       adapter: adapter,
                                       breaksite: breaksite,
                                       cutter: cutter)
        rand(5000).times do |n|
          library.junctions.create!(rname: "chr" + ((1..22).to_a + ["X","Y"]).sample.to_s,
                                    junction: rand(10000000),
                                    strand: ["+","-"].sample)
        end
      end
    end
  end
end