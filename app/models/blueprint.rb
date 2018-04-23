# frozen_string_literal: true

# Model to represent the suite-building-room structure that
# remains unchanged and can be used to import floorplan dat
# from year to year
class Blueprint < ApplicationRecord
  validates :building, presence: true
  validates :name, presence: true
  validates :size, presence: true,
                   numericality: { greater_than_or_equal_to: 0 }
  validates :rooms, presence: true

  serialize :rooms

  def blueprint_name
    "Suite Blueprint [#{:name}]"
  end
  
end
