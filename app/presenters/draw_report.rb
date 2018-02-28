# frozen_string_literal: true

# Presenter class for reporting information about draws
# Delegates to GroupsReport and the draw itself
class DrawReport < SimpleDelegator
  # Initialize a new DrawReport
  #
  # @param [Draw] draw The draw object to report on
  def initialize(draw)
    super(draw)
    @groups_report = GroupsReport.new(groups)
    @draw = draw
  end

  delegate :by_size, :with_suites, :with_suites_count, :without_rooms_count,
           :without_suites, :without_suites_count, :without_suites_by_size,
           to: :@groups_report, prefix: :groups, allow_nil: true

  # Gets the draw's suite sizes and group sizes and sorts them
  #
  # @return [Array<Integer>] A sorted array of unique group and suite sizes in
  #   the draw
  def sizes
    @sizes ||= (suite_sizes + group_sizes).uniq.sort
  end

  # Gets the draw's groups with the leader eager-loaded
  #
  # @return [ActiveRecord::Associations::CollectionProxy] The draw's groups
  def groups
    # call to #__getobj__ is necessary to avoid stack too deep errors
    @groups ||= __getobj__.groups.includes(:leader)
  end

  # Calculates the number of groups per size
  #
  # @return [Hash{Integer => Integer}] A hash mapping group sizes to the number
  #   of groups of that size
  def group_counts
    @group_counts ||= CountBySizeQuery.new(groups).call
  end

  # Calculates the number of locked groups per size
  #
  # @return [Hash{Integer => Integer}] A hash mapping group sizes to the number
  #   of locked groups of that size
  def locked_counts
    @locked_counts ||= CountBySizeQuery.new(groups.where(status: 'locked')).call
  end

  # Calculates the difference between the number of suites of a given size
  # and the number of groups of that size.
  #
  # @return [Hash{Integer => Integer}] A hash mapping sizes to the difference
  #   between the number of suites of that size and the number of groups
  def oversubscription
    @diff ||= sizes.map { |s| [s, suite_counts[s] - group_counts[s]] }.to_h
  end

  # Calculates the number of suites by size
  #
  # @return [Hash{Integer => Integer}] A hash mapping sizes to the number of
  #   available suites of that size
  def suite_counts
    @suite_counts ||= CountBySizeQuery.new(suites.available).call
  end

  # Gets the selectable suites for a given size, grouped by building
  #
  # @param [Integer] size The suite size to query for
  #
  # @return [Hash{Building => ActiveRecord::Associations::CollectionProxy}] A
  #   hash mapping buildings to avaiable, non-medical suites of the given size
  def valid_suites(size:)
    ValidSuitesQuery.new(suites.where(size: size).includes(:building)).call
                    .group_by(&:building)
  end

  # Gets the students in the draw without a group, grouped by intent,
  # without off campus students
  #
  # @return [Hash{String => ActiveRecord::Associations::CollectionProxy}] A hash
  #   with the ungrouped on campus and undeclared students in the draw
  def ungrouped_students
    @ungrouped_students ||= UngroupedStudentsQuery.new(students).call
                                                  .group_by(&:intent)
    @ungrouped_students.delete('off_campus')
    @ungrouped_students.default = []
    @ungrouped_students
  end

  # Calculates the intent metrics for a given draw
  #
  # @return [Hash{String => Integer}] a hash with intent Enum strings as keys
  #   and associated record counts as values
  def intent_metrics
    @intent ||= IntentMetricsQuery.call(draw)
  end

  private

  attr_accessor :draw
end
