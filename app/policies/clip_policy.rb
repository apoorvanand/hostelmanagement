# frozen_string_literal: true

# Class for Clip permissions
class ClipPolicy < ApplicationPolicy
  def show?
    true
  end

  def index?
    true
  end

  def create?
    user_has_uber_permission? || group.leader == user
  end

  def edit?
    update?
  end

  def destroy?
    edit?
  end

  def update?
    group.leader == user || user_has_uber_permission?
  end

  def make_clip?
    record.locked? && user_has_uber_permission? ||
      (user.group == group && group.leader == user)
  end

  def assign_lottery?
    user_has_uber_permission?
  end

  class Scope < Scope # rubocop:disable Style/Documentation
    def resolve
      scope
    end
  end
end
