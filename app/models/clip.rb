# frozen_string_literal: true

# Model to represent Clipped groups
#
# @attr draw [Draw] The draw that the clip is in.
# @attr groups [Array<Group>] The groups included in the clip.
class Clip < ApplicationRecord
  belongs_to :draw
  has_many :groups, dependent: :nullify

  validates :draw, presence: true
  validate :enough_groups
  validate :lottery_numbers_match
  validate :group_draws_match

  # Generate the group name
  #
  # @return [String] the group's name
  def name
    "#{groups.first.name} and #{groups.count - 1} others"
  end

  # Destroys the clip if it contains too few groups.
  # It is called automatically after groups in clips are destroyed.
  def clip_cleanup!
    destroy! if existing_groups.size <= 1
  end

  private

  def size
    groups.size
  end

  def existing_groups
    groups.to_a.keep_if(&:persisted?)
  end

  def enough_groups
    return if groups.size > 1
    errors.add :base, 'There must be more than one group per clip.'
  end

  def lottery_numbers_match
    lottery_number = groups.first.lottery_number
    return if groups.select(lottery_number: lottery_number).size < size
    errors.add :groups, 'do not have the same lottery numbers.'
  end

  def group_draws_match
    return if groups.select(draw: groups.first.draw).size < size
    errors.add :groups, 'are not all in the same draw.'
  end
end
