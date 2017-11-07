# frozen_string_literal: true

FactoryGirl.define do
  factory :clip do
    association :draw #, factory: :draw_with_members, groups_count: 2

    factory :clip_with_groups do
      after(:build) do |c|
        c.groups << create(:finalizing_group, draw: c.draw)
        c.groups << create(:locked_group, draw: c.draw)
      end
    end
  end
end
