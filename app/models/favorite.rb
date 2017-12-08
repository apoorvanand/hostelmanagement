# frozen_string_literal: true

# Model for relationships from Groups and Suites
class Favorite < ApplicationRecord
  belongs_to :group
  belongs_to :suite
  has_many :likes

  validates :group, presence: true
  validates :suite, presence: true

  validate :matching_draw, if: ->(m) { m.suite.present? && m.group.present? }
  validate :matching_size, if: ->(m) { m.suite.present? && m.group.present? }
  validate :suite_is_available, if: ->(m) { m.suite.present? }, on: :create

  private

  def matching_draw
    return if suite.draws.include? group.draw
    errors.add :base, "#{suite.number} is not in the same draw as the group"
  end

  def matching_size
    return if suite.size == group.size
    errors.add :base, "#{suite.number} is a different size than the group"
  end

  def suite_is_available
    return if suite.available?
    errors.add :base, "#{suite.number} is not available"
  end
end
