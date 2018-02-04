# frozen_string_literal: true

# Class for Clip permissions
class ClipPolicy < ApplicationPolicy
  def show?
    true
  end

  def create?
    (student_can_create_clip(user, user.group) || user_has_uber_permission?) &&
      record.draw.before_lottery?
  end

  def create_as_rep?
    user.rep? && user.group.present? && record.draw.before_lottery?
  end

  def edit?
    user.admin?
  end

  def update?
    edit?
  end

  def destroy?
    edit?
  end

  class Scope < Scope # rubocop:disable Style/Documentation
    def resolve
      scope
    end
  end

  private

  def student_can_create_clip(user, group)
    user_is_a_group_leader(user) && group.clip.blank?
  end
end
