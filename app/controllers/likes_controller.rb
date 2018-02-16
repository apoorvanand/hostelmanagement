# frozen_string_literal: true

# Likes Controller class
class LikesController < ApplicationController
  prepend_before_action :set_user

  def show; end

  def new
    @favorite = Favorite.new(like_params)
    Like.new(user: @user, favorite: @favorite)
  end

  def create
    @favorite = Favorite.new(group: @group, suite: @suite,
                             params: like_params)
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

  def like_params
    params.require(:like).permit(:group_id, :suite_id)
  end

  def set_user
    @user = current_user
    @group = Group.find(params[:group_id])
    @draw = Draw.find(params[:draw_id])
    @suite = Suite.find(params[:suite_id])
  end
end
