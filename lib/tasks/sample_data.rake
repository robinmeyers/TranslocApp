namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do
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
    (1..50).each do |n|
      run = "Alt%03d" % n
      completed_on = (50-n).weeks.ago
      Sequencing.create!(run: run, completed_on: completed_on)
    end

    

    Researcher.first(6).each do |researcher|
      sequencing_offset = 0
      (1..8).to_a.reverse.each do |n|
        sequencing_offset += rand(3)
        sequencing = Sequencing.offset(sequencing_offset).first
        name = researcher.name.scan(/[A-Z]/).join + "%03d" % n
        description = Faker::Lorem.sentence(5)
        assembly = ["mm9","hg19"].sample
        brkchr = ((1..22).to_a + ["X","Y"]).sample
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
        rand(1000).times do |n|
          library.junctions.create!(rname: ((1..22).to_a + ["X","Y"]).sample,
                                    junction: rand(10000000),
                                    strand: ["+","-"].sample)
        end
      end
    end
  end
end