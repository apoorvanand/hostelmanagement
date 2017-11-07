# frozen_string_literal: true

FactoryGirl.define do
  factory :clip do
    transient do
      groups_count 2
    end

    draw { create(:oversubscribed_draw, groups_count: groups_count) }
    groups { draw.groups }

    factory :clip_with_lottery_numbers do
      after(:build) do |clip|
        clip.groups.each do |group|
          group.update!(lottery_number: 1)
        end
      end
    end
  end
end
