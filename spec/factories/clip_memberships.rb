# frozen_string_literal: true

FactoryGirl.define do
  factory :clip_membership do
    transient do
      confirmed true
    end

    clip
    group { clip.groups.first }
  end
end
