# frozen_string_literal: true

# User model class for all user types. Optionally loads in sets of Devise
# modules for authentication. Validates presence of required profile fields
# (noted below).
#
# @attr email [String] the user's e-mail (required for database auth)
# @attr encrypted_password [String] the encrypted password for database
#   authentication (handled by Devise)
# @attr username [String] the user's CAS login (required for CAS auth)
# @attr role [Integer] an enum for the user's role: superuser, admin,
#   [housing] rep, or student (required)
# @attr first_name [String] the user's first name (required)
# @attr last_name [String] the user's last name (required)
# @attr intent [Integer] an enum for the user's housing intent, on_campus,
#   off_campus, or undeclared (required)
# @attr class_year [Integer] the graduating class year of the student (optional)
# @attr college [College] the college that a user is associated with (optional
#   but necessary for most authorization)
class User < ApplicationRecord
  # Determine whether or not CAS authentication is being used, must be at the
  # top of the class to be used in the Devise loading conditional below.
  #
  # @return [Boolean] true if the CAS_BASE_URL environment variable is set,
  #   false otherwise
  def self.cas_auth?
    env? 'CAS_BASE_URL'
  end

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  if cas_auth?
    devise :cas_authenticatable, :trackable
  else
    devise :database_authenticatable, :recoverable, :rememberable, :trackable,
           :validatable
  end

  belongs_to :college
  belongs_to :draw
  has_one :led_group, inverse_of: :leader, dependent: :destroy,
                      class_name: 'Group', foreign_key: :leader_id
  has_one :membership, -> { where(status: 'accepted') }, dependent: :destroy
  accepts_nested_attributes_for :membership
  has_one :group, through: :membership
  has_many :memberships, dependent: :destroy

  belongs_to :room

  validates :email, uniqueness: true
  validates :username, presence: true, if: :cas_auth?
  validates :username, uniqueness: { case_sensitive: false }, allow_nil: true
  validates :role, presence: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :intent, presence: true
  validate :room_in_suite, if: ->() { group.present? && group.suite.present? }

  enum role: %w(student admin rep superuser)
  enum intent: %w(undeclared on_campus off_campus)

  before_save :downcase_username, if: :cas_auth?

  scope :in_draw, ->(draw) { where(draw_id: draw.id) }

  # Returns the user's preferred name
  #
  # @return [String] Preferred name
  def name
    first_name
  end

  # Returns the user's preferred full name
  #
  # @return [String] First name plus last name
  def full_name
    "#{name} #{last_name}"
  end

  # Returns the user's full name with their intent in parentheses
  #
  # @return [String] Full name with user's intent in parentheses
  def full_name_with_intent
    "#{full_name} (#{pretty_intent})"
  end

  # Returns the user's intent not in snake case (replaces underscores with
  # spaces)
  #
  # @return [String] the non-snake case intent
  def pretty_intent
    intent.tr('_', ' ')
  end

  # Returns true if the user is the leader of the given group
  #
  # @return [Boolean]
  def leader_of?(group)
    self == group.leader
  end

  # Back up a user's current draw into old_draw_id and removes them from current
  # draw, also setting intent to undeclared. Does nothing if draw_id is nil.
  #
  # @return [User] the modified but unpersisted user object
  def remove_draw
    return self if draw_id.nil?
    old_draw_id = draw_id
    assign_attributes(draw_id: nil, old_draw_id: old_draw_id,
                      intent: 'undeclared')
    self
  end

  # Restores a user's draw from old_draw_id and optionally saves the current
  # draw_id to old_draw_id, also setting intent to undeclared. If the draw_id is
  # equal to the old_draw_id, will set draw_id to nil.
  #
  # @param save_current [Boolean] whether or not to assign the current draw_id
  #   value to old_draw_id, defaults to false
  # @return [User] the modified but unpersisted user object
  def restore_draw(save_current: false)
    to_save = save_current ? draw_id : nil
    new_draw_id = old_draw_id != draw_id ? old_draw_id : nil
    assign_attributes(draw_id: new_draw_id, old_draw_id: to_save,
                      intent: 'undeclared')
    self
  end

  # Override #admin? to also return true for superusers
  #
  # @return [Boolean] True for admins and superusers
  def admin?
    role == 'admin' || role == 'superuser'
  end

  # Return the associated college or a null object
  #
  # @return [College] the associated college or a null object
  def college
    super || College.new(name: 'None')
  end

  private

  def downcase_username
    username.downcase!
  end

  def cas_auth?
    User.cas_auth?
  end

  def room_in_suite
    return if !room || room.suite_id == group.suite.id
    errors.add(:room, "room must be in the user's group's suite.")
  end
end
