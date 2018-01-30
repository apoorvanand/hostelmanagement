# frozen_string_literal: true

# Policy for SuiteAssignments
class SuiteAssignmentPolicy < ApplicationPolicy
  def new?
    return can_bulk_assign? unless single_assignment?
    return can_drawless_assign? unless draw.present?
    return false unless draw.suite_selection?
    draw.next_group?(record.groups.first) &&
      (student_can_select_suite? || user_has_uber_permission?)
  end

  def create?
    new?
  end

  def destroy?
    user_has_uber_permission?
  end

  class Scope < Scope # rubocop:disable Style/Documentation
    def resolve
      scope
    end
  end

  private

  def draw
    @draw ||= record.draw || record.groups.first.draw
  end

  def single_assignment?
    record.groups.size == 1
  end

  def can_bulk_assign?
    user_has_uber_permission? && draw.admin_selection? && draw.suite_selection?
  end

  def can_drawless_assign?
    user.admin?
  end

  def student_can_select_suite?
    return false unless draw == user.draw
    draw.student_selection? && user.leader_of?(record.groups.first)
  end
end
