class Clip < ApplicationRecord
  belongs_to :draw
  has_many :groups

  validates :name, presence: true
  #validates :lottery_number, numericality: { allow_nil: true }



end
