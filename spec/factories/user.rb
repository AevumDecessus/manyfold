FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    username { Faker::Internet.username specifier: 3, separators: [] }
    password { Faker::Internet.password max_length: 32, min_length: 32, mix_case: true, special_characters: true }

    factory :admin do
      after(:create) { |a| a.add_role :administrator }
    end

    factory :editor do
      after(:create) { |a| a.add_role :editor }
    end

    factory :contributor do
      after(:create) { |a| a.add_role :contributor }
    end
  end
end
