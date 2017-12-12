# frozen_string_literal: true

# Model to represent confirmation stage of groups joining clips.
# @attr group [Group] The group of the membership.
# @attr clip [Clip] The clip of the membership.
# @attr confirmed [Boolean] Confirmation for membership. Defaults to false.
class ClipMembership < ApplicationRecord
  belongs_to :group
  belongs_to :clip

  validates :group, presence: true, uniqueness: { scope: :clip }
  validates :clip, presence: true
  validate :matching_draw, if: ->(m) { m.clip.present? && m.group.present? }
  validate :group_not_in_clip, if: ->(m) { m.group.present? }, on: :create

  before_update :freeze_clip_and_group

  after_create :send_invitation
  after_save :destroy_pending,
             if: ->() { saved_change_to_confirmed && confirmed }
  after_save :send_joined_email,
             if: ->() { saved_change_to_confirmed && confirmed }

  after_destroy :send_left_email, if: ->() { confirmed }
  after_destroy :run_clip_cleanup

  private

  def send_invitation
    # TODO: In the clips_controller make the creator of the clip start
    # confirmed if they will be in the clip
    return if confirmed
    StudentMailer.invited_to_clip(invited: group, clip: clip,
                                  college: College.first).deliver_later
  end

  # TODO: Abstract this to a service object that you call during
  # a clips_controller#confirm_clip_membership controller action
  def send_joined_email
    clip.send_joined_email(group)
  end

  # TODO: Abstract this to a service object that you call during
  # a clips_controller#leave_clip action
  def send_left_email
    clip.send_left_email(group)
  end

  def run_clip_cleanup
    clip.clip_cleanup!
  end

  def matching_draw
    return if group.draw == clip.draw
    errors.add :base, "#{group.name} is not in the same draw as the clip"
  end

  def group_not_in_clip
    return unless group.clip && group.clip != clip
    errors.add :base, "#{group.name} already belongs to another clip"
  end

  def freeze_clip_and_group
    return unless will_save_change_to_clip_id? || will_save_change_to_group_id?
    throw(:abort)
  end

  def destroy_pending
    group.clip_memberships.where.not(id: id).destroy_all
  end
end
