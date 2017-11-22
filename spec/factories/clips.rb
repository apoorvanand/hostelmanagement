# frozen_string_literal: true

FactoryGirl.define do
  factory :clip do
    transient do
      groups_count 2
    end

    draw
    groups { build_list(:group_from_draw, groups_count, draw: draw) }

    factory :clip_with_lottery_numbers do
      after(:build) do |clip|
        clip.lottery_number = 1
      end
    end
  end
end
