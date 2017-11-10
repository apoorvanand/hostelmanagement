# frozen_string_literal: true

# Query to return the groups and clips ready for lottery
class GroupsForLotteryQuery
  # See IntentMetricsQuery for explanation.
  class << self
    delegate :call, to: :new
  end

  # Initialize a GroupsForLotteryQuery
  def initialize
    @relation = DrawClipGroup.includes(
      [group: :leader], [clip: [clip_memberships: [group: :leader]]]
    )
  end

  # Execute the groups for lottery query.
  #
  # @param draw [Draw] The draw to restrict scope to.
  # @return [Array<Group,Clip>] The groups and clips ready for lottery numbers.
  def call(draw:)
    @relation.where(draw: draw).map(&:to_obj)
             .sort_by { |result| result.leader.last_name }
  end
end
