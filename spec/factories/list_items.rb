FactoryBot.define do
  factory :list_item do
    user
    book
    rating { Faker::Number.between(from: 1, to: 5) }
    notes { "sample note" }
    start_date { Time.now }
    finish_date { Time.now }
  end
end
