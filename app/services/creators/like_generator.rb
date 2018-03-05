# frozen_string_literal: true

#
# Service object to lock groups
class LikeGenerator < Creator
  include Callable

  # Initialize the favorite
  def initialize(favorite:, user:)
    @favorite ||= favorite 
    @user ||= user
    make_associated_like
  end

  private

  def make_associated_like
    @user = current_user unless @user
    like = Like.new(user: @user, favorite: @favorite)
  end
end
