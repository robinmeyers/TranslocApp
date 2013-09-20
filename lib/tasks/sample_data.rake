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

    

    Researcher.all(limit: 6).each do |researcher|
      sequencing_offset = 0
      (1..8).to_a.reverse.each do |n|
        sequencing_offset += rand(3)
        sequencing = Sequencing.offset(sequencing_offset).first
        name = researcher.name.scan(/[A-Z]/).join + "%03d" % n
        researcher.experiments.create!(sequencing: sequencing, name: name)
      end
    end
  end
end