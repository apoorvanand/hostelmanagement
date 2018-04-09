# frozen_string_literal: true

# Helper module for suite assignments
module SuiteAssignmentsHelper
  def show_skip_btn?(draw)
    draw.present? && policy(draw).group_actions?
  end
end
