FactoryBot.define do
  factory :model_file do
    filename { Faker::File.file_name(ext: "stl") }
    model
  end
end
