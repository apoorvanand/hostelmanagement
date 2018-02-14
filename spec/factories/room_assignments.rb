# frozen_string_literal: true

FactoryGirl.define do
  factory :room_assignment do
    association :user, factory: :student_in_draw, intent: 'on_campus'
    room { build(:suite_with_rooms).room }
  end
end
