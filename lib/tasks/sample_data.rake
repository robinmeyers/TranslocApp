namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do

    require 'csv'
    require 'rubystats'




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
        chromosomes = Assembly.find_by(name: assembly).chromosomes
        chr = chromosomes.sample
        bstart = rand(chr.size)+1
        bend = bstart + rand(500)
        strand = ["+","-"].sample
        mid = ["A","C","G","T"].values_at(*Array.new(rand(10)){rand(4)}).join
        primer = ["A","C","G","T"].values_at(*Array.new(rand(10)+15){rand(4)}).join
        adapter = ["A","C","G","T"].values_at(*Array.new(rand(10)+15){rand(4)}).join
        cutter = ["AGCT","GGAA",""].sample
        library = researcher.libraries.create!(sequencing: sequencing,
                                       name: name,
                                       description: description,
                                       assembly: assembly,
                                       chr: chr.name,
                                       bstart: bstart,
                                       bend: bend,
                                       strand: strand,
                                       mid: mid,
                                       primer: primer,
                                       adapter: adapter,
                                       cutter: cutter)
        junctions = []
        gen = Rubystats::NormalDistribution.new(bstart, 2000000)
        (rand(2000)+2000).times do |n|
          r = rand(2)
          if r > 0
            chr = chr
            junction = gen.rng
            junction = rand(chr.size)+1 if (junction < 1 || junction > chr.size)
            s = rand(4)
            strand = s > 0 ? strand : ["+","-"].sample
          else
            chr = chromosomes.sample
            junction = rand(chr.size)+1
            strand = ["+","-"].sample
          end
          junctions.push({rname: chr.name, junction: junction, strand: strand})
        end
        library.junctions.create!(junctions)
      end
    end
  end
end