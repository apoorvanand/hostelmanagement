# frozen_string_literal: true

FactoryGirl.define do
  factory :clip do
    transient do
      groups_count 2
    end

    draw
    groups { build_list(:group_from_draw, groups_count, draw: draw) }

    after(:build) do |clip|
      clip.clip_memberships.each { |m| m.confirmed = true }
    end

    factory :clip_with_lottery_numbers do
      after(:build) do |clip|
        clip.groups.each { |group| group.lottery_number = 1 }
      end
    end
  end
end
