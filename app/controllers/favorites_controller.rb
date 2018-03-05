# frozen_string_literal: true

# Favorites Controller class
class FavoritesController < ApplicationController
  prepend_before_action :set_params

  def show; end

  def new
    Favorite.new(group: group, suite: suite)
  end

  def create
    @favorite = Favorite.new(group: group, suite: suite)
    handle_action(action: 'new', **favorite)
    LikeGenerator.create!(@favorite)
  end

  def delete
    Destroyer.new(object: @favorite, name_method: :name).destroy
    path = params[:redirect_path] || draw_path(@draw)
    handle_action(**result, path: path)
  end

  def edit; end

  private

  def set_params
    @group = Group.find(params[:group_id])
    @suite = Suite.find(params[:suite_id])
  end
end
