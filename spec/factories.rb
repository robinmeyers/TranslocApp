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

end