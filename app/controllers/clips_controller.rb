# frozen_string_literal: true

# Controller for Groups
class ClipsController < ApplicationController
  layout 'application_with_sidebar', except: %i(new create edit update index)
  prepend_before_action :set_clip, except: %i(new create index)
  prepend_before_action :set_draw
  before_action :authorize_draw!, except: %i(show assign_lottery index)

  def show; end

  def index
    @clips = @draw.clips
    # .includes(:leader, :members).order('users.last_name')
    # .group_by(&:size).sort.to_h
  end

  def create
    result = Creator.create!(params: clip_params, klass: Clip,
                             name_method: :name)
    @draw = result[:record]
    handle_action(action: 'new', **result)
  end

  def edit; end

  ### Do we even need this? ###
  def update
    result = Updater.update(object: @clip, name_method: :name,
                            params: clip_params)
    @clip = result[:record]
    handle_action(action: 'edit', **result)
  end

  def destroy
    result = Destroyer.destroy(object: @clip, name_method: :name)
    handle_action(path: draw_groups_path(@draw), **result)
  end

  def assign_lottery
    number = if clip_params['lottery_number'].empty?
               nil
             else
               clip_params['lottery_number'].to_i
             end
    @color_class = @clip.update_lottery(number: number) ? 'success' : 'failure'
  end

  private

  def authorize!
    if @clip
      authorize @clip
    else
      authorize Clip
    end
  end

  def authorize_draw!
    authorize @draw, :clip_actions?
  end

  def clip_params
    params.require(:clip).permit(:lottery_number)
  end

  def set_clip
    @clip = Clip.find(params[:id])
  end

  def set_draw
    @draw = Draw.find(params[:draw_id])
  end
end
