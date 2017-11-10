# frozen_string_literal: true

# A view-backed model used to find clips and groups that do not have clips in
# order to assign them lottery numbers.
#
# @attr draw [Draw] The draw that the group or clip is associated with.
# @attr clip [Clip] A clip that exists in the database. This attribute will be
# nil if a group value exists.
# @attr group [Group] A group that does not have a clip in the database. Will be
# nil if a clip value exists.
class DrawClipGroup < ApplicationRecord
  belongs_to :draw
  belongs_to :clip
  belongs_to :group

  # Converts a row in the view to the object it's referencing
  #
  # @return [Clip,Group] the clip or the group in the row
  def to_obj
    clip || group
  end

  private

  def readonly?
    true
  end
end
