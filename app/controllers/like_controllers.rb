# frozen_string_literal: true

# Like Controller class
class LikesController < ApplicationController
  prepend_before_action :set_user

  def show; end

  def new; end

  def create
  	@favorite = Favorite.create(group: @group, suite: @suite)
  	result = Like.create(user: @user, favorite: @favorite)
  	@like = result[:record]
  	handle_action(action: 'new', **result)
  end

  def delete
  	result = Destroyer.new(object: @like, name_method: :name).destroy
    path = params[:redirect_path] || draw_path(@draw)
    handle_action(**result, path: path)
 	end

  def edit; end

  private

  def like_params
  	p = params.require(:like).permit(%i(suite_id))
    p.reject { |v| v.empty? }
  end

  def set_user
    @user = current_user
    @group = user.group
    @suite = Suite.find(params[:suite_id])
  end
end
