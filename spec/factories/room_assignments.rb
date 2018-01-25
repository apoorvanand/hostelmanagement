# frozen_string_literal: true

FactoryGirl.define do
  factory :room_assignment do
    room
    user

    after(:build) do |obj|
      g = if obj.user.group.blank?
            create(:group, leader: obj.user)
          else
            obj.user.group
          end
      g.update!(suite: obj.room.suite)
      obj.user.reload
    end
  end
end
