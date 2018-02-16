# frozen_string_literal: true

# Class for Like permissions
class LikePolicy < ApplicationPolicy
  def initialize(user, suite)
    @user ||= user
    @suite ||= suite
  end

  def show?
    !user.admin? && (user.group&.finalizing? || user.group&.locked?) &&
      (user.group&.size == @suite.size)
  end

  def new?
    show?
  end

  def create?
    show?
  end

  def edit?
    show?
  end

  def delete?
    show?
  end
end
