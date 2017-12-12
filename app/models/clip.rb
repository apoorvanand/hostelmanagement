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

  before_update ->() { throw(:abort) if will_save_change_to_draw_id? }
  before_destroy :notify_groups_of_disband

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

  # Update the lottery number of the groups inside the clip
  #
  # @param number [Integer] the lottery number to assign to the clip
  # @return [Boolean] true if the update was successful, false otherwise
  # rubocop:disable SkipsModelValidations
  def update_lottery(number:)
    return false unless number.is_a?(Numeric) || number.is_a?(NilClass)
    groups.update_all(lottery_number: number).positive?
  end
  # rubocop:enable SkipsModelValidations

  # Return the path to #assign_lottery. Used in /views/draw/_lottery_form.erb
  # @return [Symbol] :assign_lottery_draw_clip_path
  def lottery_form_path_method
    :assign_lottery_draw_clip_path
  end

  # Return the path to #show. Used in /views/draw/_lottery_form.erb
  # @return [Symbol] :draw_clip_path
  def draw_self_path_method
    :draw_clip_path
  end

  # Return the first leader of the group
  # @return [User] leader of the first group of the clip
  def leader
    groups.first.leader
  end

  # TODO: Abstract to the clips controller
  def send_joined_email(joining_group)
    groups_to_notify = existing_groups - [joining_group]
    groups_to_notify.each do |g|
      StudentMailer.joined_clip(joining_group: joining_group, group: g,
                                college: College.first).deliver_later
    end
  end

  # TODO: Abstract to the clips controller
  def send_left_email(leaving_group)
    existing_groups.each do |g|
      StudentMailer.left_clip(leaving_group: leaving_group, group: g,
                              college: College.first).deliver_later
    end
  end

  private

  def existing_groups
    # includes(:clip_membership) is needed because otherwise groups will
    # still include groups with deleted memberships for some reason
    groups.includes(:clip_membership).to_a.keep_if(&:persisted?)
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

  def notify_groups_of_disband
    groups.each do |g|
      StudentMailer.clip_disband_notice(group: g,
                                        college: College.first).deliver_later
    end
  end
end
