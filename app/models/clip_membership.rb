# frozen_string_literal: true

# Model to represent confirmation stage of groups joining clips.
# @attr group [Group] The group of the membership.
# @attr clip [Clip] The clip of the membership.
# @attr confirmed [Boolean] Confirmation for membership. Defaults to false.
class ClipMembership < ApplicationRecord
  belongs_to :group
  belongs_to :clip

  validates :group, presence: true
  validates :clip, presence: true

  after_create :send_invitations

  def send_invitations

  end
end
