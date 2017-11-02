# frozen_string_literal: true

# Controller for Clip memberships
class ClipMembershipsController < ApplicationController
  prepend_before_action :set_clip_membership
  before_action :set_clip
  before_action :set_draw, only: %i(destroy)

  def update
    result = ClipMembershipUpdater.update(clip_membership: @clip_membership,
                                          params: { confirmed: true })
    handle_action(path: clip_path(@clip), **result)
  end

  def destroy
    result = ClipMembershipDestroyer.destroy(clip_membership: @clip_membership)
    handle_action(path: draw_path(@draw), **result)
  end

  private

  def authorize!
    authorize @clip_membership
  end

  def set_clip_membership
    @clip_membership = ClipMembership.includes(:clip).find(params[:id])
  end

  def set_clip
    @clip = @clip_membership.clip
  end

  def set_draw
    @draw = @clip.draw
  end
end
