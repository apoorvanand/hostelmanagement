# frozen_string_literal: true

# Class for Like permissions
class LikePolicy < ApplicationPolicy
  attr_reader :user, :like

  def initialize(user, like)
    @user ||= user
    @suite ||= like&.favorite&.suite
  end

  def show?
    !user.admin? && (user.group&.finalizing? || user.group&.locked?)
  end

  def new?
    show? && (user.group&.size == @suite.size)
  end

  def create?
    new?
  end

  def edit?
    show?
  end

  def delete?
    show?
  end

  def student_in_group?
    !user.admin? && user.membership
  end
end
