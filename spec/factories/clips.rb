FactoryGirl.define do
  factory :clip do
    name "MyString"
    association :draw, factory: :draw
    #lottery_number 1
  end
end
