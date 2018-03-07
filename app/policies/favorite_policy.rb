# frozen_string_literal: true

# Class for Favorite permissions
class FavoritePolicy < ApplicationPolicy
  attr_reader :group, :suite

  def initialize(group, suite)
    @group ||= group
    @suite ||= suite
  end

  def show?
    (group.finalizing? || group.locked?)
  end

  def new?
    show? && (group.size == suite.size)
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
end
