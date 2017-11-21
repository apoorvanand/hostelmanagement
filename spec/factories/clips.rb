# frozen_string_literal: true

FactoryGirl.define do
  factory :clip do
    transient do
      groups_count 2
    end

    draw

    after(:build) do |clip, e|
      clip.groups = create_list(:group_from_draw, e.groups_count,
                                draw: clip.draw)
    end

    factory :clip_with_lottery_numbers do
      after(:build) do |clip|
        clip.lottery_number = 1
      end
    end
  end
end
