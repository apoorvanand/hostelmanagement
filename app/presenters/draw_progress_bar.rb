class DrawProgressBar
  def initialize(draw_report:)
    @draw = draw_report
  end

  def intent
    return @i_hash if i_hash
    @i_total ||= draw.student_count.to_f
    @i_hash ||= draw.intent_metrics.map do |k, v| 
      [k.to_sym, (v / i_total) * 100] 
    end.to_h
    @i_hash.default = 0
    @i_hash
  end

  def group_formation
    @g_hash ||= group_formation_counts.map do |k, v|
      [k, v / on_campus_count * 100]
    end.to_h
  end

  def group_formation_counts
    @gc_hash ||= { in_groups: grouped_count, not_in_groups: ungrouped_count }
  end


  #    (draw.groups_with_suites_count / draw.group_count.to_f) * 100,
  #    draw.groups_with_suites_count,
  #    draw.groups_without_suites_count / draw.group_count.to_f) * 100
  #    draw.groups_without_suites_count,
  #
  #    ((draw.groups_with_suites_count - draw.groups_without_rooms_count) / 
  #       draw.groups_with_suites_count.to_f)  * 100,
  #    draw.groups_with_suites_count - draw.groups_without_rooms_count,
  #    (draw.groups_without_rooms_count / draw.groups_with_suites_count.to_f) * 100,
  #    draw.groups_without_rooms_count,

  private

  attr_reader :draw
  attr_reader :i_total, :i_hash
  attr_reader :g_hash

  def on_campus_count
    @on_campus_count ||= draw.intent_metrics['on_campus'].to_f
  end

  def ungrouped_count
    @ungrouped_count ||= draw.ungrouped_students['on_campus'].count
  end

  def grouped_count
    @grouped_count ||= (on_campus_count - ungrouped_count).to_i
  end
end
