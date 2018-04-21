# frozen_string_literal: true

FactoryGirl.define do
  factory :blueprint do
    building 'mybuilding'
    name 'myname'
    size 1
    rooms '[a1, a2, a3]'
  end
end
