# frozen_string_literal: true

# Join model for users <-> rooms
#
# @attr draw [Draw] the draw associated with the room assignment, if any
# @attr room [Room] the room associated with the room assignment
# @attr user [User] the user associated with the room assignment
class RoomAssignment < ApplicationRecord
  belongs_to :room
  belongs_to :user

  has_one :draw, through: :user
  has_one :suite, through: :room
  has_one :group, through: :user

  validates :room, presence: true, uniqueness: true
  validates :user, presence: true, uniqueness: true

  validate :suite_draw_matches_user_draw
  validate :suite_group_matches_user_group

  private

  def suite_draw_matches_user_draw
    suite.draws.include?(draw)
  end

  def suite_group_matches_user_group
    suite.group == group
  end
end
