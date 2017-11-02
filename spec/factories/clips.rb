# frozen_string_literal: true

FactoryGirl.define do
  factory :clip do
    transient do
      groups_count 2
    end

    draw { create(:draw, status: 'pre_lottery') }
    groups { build_list(:group_from_draw, groups_count, draw: draw) }
  end
end
