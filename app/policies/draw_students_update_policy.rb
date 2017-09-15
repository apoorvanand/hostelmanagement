# frozen_string_literal: true

# Policies for updating students
class DrawStudentsUpdatePolicy < ApplicationPolicy
  def index?
    user_has_uber_permission?
  end

  def edit?
    user_has_uber_permission?
  end

  def update?
    user_has_uber_permission?
  end

  def bulk_assign?
    user_has_uber_permission?
  end
end
