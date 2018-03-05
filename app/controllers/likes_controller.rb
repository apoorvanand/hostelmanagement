# frozen_string_literal: true

# Likes Controller class
class LikesController < ApplicationController
  prepend_before_action :set_params

  def show; end

  def new
    Like.new(user: @user, favorite: @favorite)
  end

  def create
    @like = Like.new(user: @user, favorite: @favorite)
    handle_action(action: 'new', **like)
  end

  def delete
    Destroyer.new(object: @like, name_method: :name).destroy
    path = params[:redirect_path] || draw_path(@draw)
    handle_action(**result, path: path)
  end

  def edit; end

  private

  def set_params
    @user = current_user
    @favorite = Favorite.find(params[:favorite_id])
  end
end
