# frozen_string_literal: true

# Controller for LotteryAssignments
class LotteryAssignmentsController < ApplicationController
  prepend_before_action :set_draw_with_eager_load, only: %(index)
  prepend_before_action :set_draw, except: %(index)
  prepend_before_action :set_lottery_assignment, only: %i(update)

  def index
    @lotteries = LotteriesForLotteryQuery.call(draw: @draw)
  end

  def create
    result = Creator.create!(klass: LotteryAssignment,
                             params: lottery_assignment_params,
                             name_method: :number)
    @lottery = result[:record]
    @color_class = result[:msg].keys.first.to_s
  end

  def update
    result = Updater.update(object: @lottery,
                            params: lottery_assignment_params,
                            name_method: :number)
    @color_class = result[:msg].keys.first.to_s
  end

  private

  def lottery_assignment_params
    params.require(:lottery_assignment)
          .permit(:clip_id, :draw_id, :group_ids, :number)
  end

  def set_lottery_assignment
    @lottery = LotteryAssignment.includes(:groups).find(params[:id])
  end

  def set_draw_with_eager_load
    @draw = Draw.includes(groups: :leader).includes(:lottery_assignments)
                .find(params[:draw_id])
  end

  def set_draw
    @draw = Draw.find(params[:draw_id])
  end

  def authorize!
    if @lottery
      authorize @lottery
    else
      authorize LotteryAssignment.new(draw: @draw)
    end
  end
end
