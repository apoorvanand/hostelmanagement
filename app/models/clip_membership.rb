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
  validate :matching_draw, if: ->(m) { m.user.present? && m.group.present? }

  after_create :send_invitations

  def send_invitations
    return if confirmed
    StudentMailer.invited_to_clip(invited: group, clip: clip,
                                  college: College.first).deliver_later
  end

  private

  def matching_draw
    return if group.draw == clip.draw
    errors.add :base, "#{group.name} is not in the same draw as the clip"
  end
end
