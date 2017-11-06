class Clip < ApplicationRecord
  belongs_to :draw
  has_many :groups

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
    destroy! if groups.count <= 1
  end

  private

  def validate_lottery_numbers
    return if groups.where.not(lottery_number: groups.first.lottery_number).empty?
    errors.add :groups, 'do not have the same lottery numbers.'
  end

  def validate_group_draws
    return if groups.where.not(draw: groups.first.draw).empty?
    errors.add :groups, 'are not all in the same draw.'
  end

  def validate_multiple_groups_in_clip
    return if groups.count > 1
    errors.add :base, 'There must be more than one group per clip.'
  end
end
