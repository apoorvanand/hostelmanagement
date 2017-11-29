# frozen_string_literal: true

# Controller for Groups
class ClipsController < ApplicationController
  layout 'application_with_sidebar'
  prepend_before_action :set_clip
  prepend_before_action :set_draw

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
