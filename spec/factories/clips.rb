FactoryGirl.define do
  factory :clip do
    association :draw, factory: :draw_with_members
  end
end
