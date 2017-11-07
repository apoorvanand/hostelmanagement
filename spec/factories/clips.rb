# frozen_string_literal: true

FactoryGirl.define do
  factory :clip do
    association :draw, factory: :oversubscribed_draw, groups_count: 2
    groups {draw.groups}

    factory :clip_with_lottery_numbers do
      groups.each do |group|
        group.update!(lottery_number: 1)
      end
    end

  end
end
