# frozen_string_literal: true

class Blueprint < ApplicationRecord
  validates :building, presence: true
  validates :name, presence: true
  validates :size, presence: true,
                   numericality: { greater_than_or_equal_to: 0 }
  validates :rooms, presence: true

  serialize :rooms

end