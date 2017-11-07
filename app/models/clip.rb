# frozen_string_literal: true

# Model to represent Housing Draws.
#
# @attr name [String] The name of the housing draw -- e.g. "Junior Draw 2016"
class Clip < ApplicationRecord
  belongs_to :draw
  has_many :groups, dependent: :nullify

  validate :validate_multiple_groups_in_clip
  validate :validate_lottery_numbers
  validate :validate_group_draws

  # Generate the group name
  #
  # @return [String] the group's name
  def name
    "#{groups.first.name} and #{groups.count - 1} others"
  end

  def clip_cleanup!
    destroy! if groups.to_a.keep_if(&:persisted?).size <= 1
  end

  private

  def size
    groups.size
  end

  def validate_lottery_numbers
    lottery_number = groups.first.lottery_number
    return if groups.where(lottery_number: lottery_number).size < size
    errors.add :groups, 'do not have the same lottery numbers.'
  end

  def validate_group_draws
    return if groups.where(draw: groups.first.draw).size < size
    errors.add :groups, 'are not all in the same draw.'
  end

  def validate_multiple_groups_in_clip
    return if groups.size > 1
    errors.add :base, 'There must be more than one group per clip.'
  end
end
