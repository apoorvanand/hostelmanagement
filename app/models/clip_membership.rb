# frozen_string_literal: true

# Model to represent confirmation stage of groups joining clips.
# @attr group [Group] The group of the membership.
# @attr clip [Clip] The clip of the membership.
# @attr confirmed [Boolean] Confirmation for membership. Defaults to false.
class ClipMembership < ApplicationRecord
  belongs_to :group
  belongs_to :clip

  validates :group, presence: { uniqueness: { scope: :clip } }
  validates :clip, presence: true
  validates :confirmed, inclusion: { in: [true, false] }
  validate :matching_draw, if: ->(m) { m.clip.present? && m.group.present? }
  validate :group_not_in_clip, if: ->(m) { m.group.present? }, on: :create

  after_create :send_invitations
  after_save :send_joined_email,
             if: ->() { saved_change_to_confirmed && confirmed }
  after_destroy :send_left_email, if: ->() { confirmed }
  after_destroy :run_clip_cleanup

  private

  def send_invitations
    return if confirmed # creators of the clip will start confirmed
    # StudentMailer.invited_to_clip(invited: group, clip: clip,
    #                              college: College.first).deliver_later
  end

  def send_joined_email
    # Need to send email when you join a clip
  end

  def send_left_email
    # Need to send email when you leave a clip
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
end
