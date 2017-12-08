# frozen_string_literal: true

# Model for relationships between Favorites and Users
class Like < ApplicationRecord
  belongs_to :user
  belongs_to :favorite

  validates :user, presence: true
  validates :favorite, presence: true

  validate :members_can_only_like_a_suite_once,
           if: ->(m) { m.user.present? && m.favorite.present? }

  before_destroy :check_to_remove_favorite

  def members_can_only_like_a_suite_once
    return unless Like.exists?(user: user, favorite: favorite)
    errors.add :base, 'Users can only like each suite once'
  end

  def check_to_remove_favorite
    return if favorite.likes.count > 1
    favorite.destroy
  end
end
