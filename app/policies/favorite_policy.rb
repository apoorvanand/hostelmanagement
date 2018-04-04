# frozen_string_literal: true

# Class for Favorite permissions
class FavoritePolicy < ApplicationPolicy
  attr_reader :group, :suite

  def initialize(group, suite)
    if group
      @group = group
    else
      @group = favorite.group
    end
    if suite
      @suite = suite
    else
      @suite = favorite.suite unless suite
    end
  end

  def show?
    (@group.finalizing? || @group.locked?)
  end

  def new?
    show? && (@group.size == @suite.size)
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
