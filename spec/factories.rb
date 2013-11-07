FactoryGirl.define do
  factory :researcher do
    sequence(:name)  { |n| "Person #{n}" }
    sequence(:email) { |n| "person_#{n}@example.com"}
    password "foobar"
    password_confirmation "foobar"
    
    factory :admin do
      admin true
    end
  end

  factory :sequencing do
    sequence(:run) { |n| "Alt%03d" % n }

    factory :completed_sequencing do
      sequence(:completed_on) { |n| n.weeks.from_now }
    end
  end

  factory :library do
    name "Exp001"
    researcher
    sequencing
    assembly "mm9"
    mid ""
    primer "ACGTACGTACGT"
    breaksite "ACGTACGTACGTACGTACGTACGTACGTACGTACGTACGTACGTACGT"
    adapter "ACGTACGT"
    brkchr "15"
    brkstart 1000000
    brkend 10000001
    description "Test library"
    cutter "TTAA"
    brkstrand "-"
  end

  factory :junction do
    library
    rname "15"
    junction 1000000
    rstart 1000000
    rend 1000010
    qname "XXXXXX"
    qstart 100
    qend 110
  end

end