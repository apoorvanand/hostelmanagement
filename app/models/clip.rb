# frozen_string_literal: true

# Model to represent clipped groups.  When two or more groups want to select
# suites at the same time a clip should be created.  This allows for all groups
# in the clip to be assigned the same lottery number and therefore allow them
# all to select suites at the same time.
#
# @attr draw [Draw] The draw that the clip is in.
# @attr groups [Array<Group>] The groups included in the clip.
class Clip < ApplicationRecord
  belongs_to :draw
  has_many :clip_memberships, dependent: :delete_all
  has_many :groups, -> { where(clip_memberships: { confirmed: true }) },
           through: :clip_memberships

  validate :enough_groups
  validate :group_draws_match
  validate :lottery_numbers_match, on: :create

  after_create :send_invitations
  before_update ->() { throw(:abort) if will_save_change_to_draw_id? }
  after_destroy :notify_groups_of_disband

  # Generate the clip's name
  #
  # @return [String] the clip's name
  def name
    "#{groups.first.name} and #{groups.count - 1} others"
  end

  # Destroys the clip if it contains too few groups. It is called
  # automatically after groups in clips are destroyed or change their draw.
  #
  # @return [Clip] the clip destroyed or nil if no change
  def clip_cleanup!
    destroy! if existing_groups.length <= 1
  end

  # Returns the lottery number associated with the clip
  #
  # @return [Integer] the lottery number of the clip
  def lottery_number
    groups.first.lottery_number
  end

  # Override for the lottery number assignment for duck typing with groups
  #
  # @param number [Integer] the lottery number to assign to the clip
  # @return [Object] the object passed as the param
  def lottery_number=(number)
    groups.each { |group| group.lottery_number = number }
  end

  private

  def existing_groups
    clip_memberships.to_a.keep_if(&:persisted?)
  end

  def enough_groups
    return if groups.length > 1
    errors.add :base, 'There must be more than one group per clip.'
  end

  def lottery_numbers_match
    return if groups.map(&:lottery_number).uniq.length == 1
    errors.add :groups, 'do not all have the same lottery number.'
  end

  def group_draws_match
    return if groups.map(&:draw_id).uniq == [draw_id]
    errors.add :groups, 'are not all in the same draw.'
  end

  def send_invitations
    groups.each do |g|
      # should the creators of the clip start confirmed?
      return if clip_membership.confirmed
      StudentMailer.invited_to_clip(invited: g, clip: self,
                                    college: College.first).deliver_later
    end
  end

  def notify_groups_of_disband
    groups.each do |g|
      StudentMailer.clip_disband_notice(group: g, clip: self,
                                        college: College.first).deliver_later
    end
  end
end
