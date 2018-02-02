# frozen_string_literal: true

# Class for Like permissions
class LikePolicy < ApplicationPolicy
  attr_reader :user, :group

  def initiatilize(user, favorite)
    @user = user
    @favorite = favorite
  end

  def show?
    !user.admin? && (user.group&.finalizing? || user.group&.locked?)
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
