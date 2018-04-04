# frozen_string_literal: true

# Controller for Draws
class DrawSuitesController < ApplicationController
  prepend_before_action :set_draw
  before_action :set_form_data, only: %i(new edit)

  def index
    logger.debug "\ndraw"
    logger.debug @draw.name
    logger.debug "\n"
    # Query to return available non-medical suites,
    suites = ValidSuitesQuery.new(@draw.suites.includes(:rooms)).call
    # Query to return all of the suite sizes in the database.
    @all_sizes = SuiteSizesQuery.new(suites).call
    logger.debug "\nsuites"
    logger.debug suites
    logger.debug "\nall sizes"
    logger.debug @all_sizes
    logger.debug "\n"
    @suites_by_size = SuitesBySizeQuery.new(suites).call
    @suites_by_size.default = []
    logger.debug "\nsuites by size"
    logger.debug @all_sizes
    logger.debug "\n"
  end

  def edit_collection
    prepare_suites_edit_data
  end

  def update_collection
    result = DrawSuitesUpdate.update(draw: @draw, params: suites_update_params)


    logger.debug "\nsuites_update_params"
    logger.debug suites_update_params

    logger.debug "\nresult"
    logger.debug result

    @suites_update = result[:update_object]

    logger.debug "\nsuites update"
    logger.debug @suites_update


    if @suites_update
      prepare_suites_edit_data
      result[:action] = 'edit_collection'
    else
      result[:path] = draw_suites_path(@draw)
    end
    handle_action(**result)
  end

  private

  def suite_edit_param_hash
    suite_edit_sizes.flat_map do |s|
      DrawSuitesUpdate::CONSOLIDATED_ATTRS.map { |p| ["#{p}_#{s}".to_sym, []] }
    end.to_h
  end

  def suite_edit_sizes
    @suite_edit_sizes ||= SuiteSizesQuery.new(Suite.available).call
  end

  def authorize!
    if @draw_suite
      authorize @draw_suite
    else
      authorize DrawSuite.new(draw: @draw)
    end
  end

  def prepare_suites_edit_data # rubocop: disable MethodLength
    # Query to return available non-medical suites,
    all_suites = ValidSuitesQuery.call
    logger.debug "\nall_suites"
    logger.debug all_suites
    logger.debug "\n"

    # draw suites update here... suites update contains the suite id for this draw id
    @suites_update ||= DrawSuitesUpdate.new(draw: @draw)
    logger.debug "\nsuites_update"
    logger.debug @suites_update
    logger.debug "\n"


    logger.debug "\nsuite_ids for suites update"
    logger.debug @suites_update.suite_ids
    logger.debug "\n"

    @current_suites = suite_hash_merge(
      ValidSuitesQuery.new(@draw.suites.includes(:draws)).call
    )
    @drawless_suites = suite_hash_merge(
      DrawlessSuitesQuery.new(all_suites).call
    )
    @drawn_suites = suite_hash_merge(
      SuitesInOtherDrawsQuery.new(all_suites).call(draw: @draw)
    )

    logger.debug "\ncurrent_suites"
    logger.debug @current_suites

    logger.debug "\ndrawless_suites"
    logger.debug @drawless_suites

    logger.debug "\ndrawn_suites"
    logger.debug @drawn_suites
    logger.debug "\n"
  end

  # rubocop: enable MethodLength

  def suite_hash_merge(queried_suites)
    @suite_sizes ||= SuiteSizesQuery.new(ValidSuitesQuery.call).call
    empty_suite_hash = @suite_sizes.map { |s| [s, []] }.to_h
    empty_suite_hash.merge(queried_suites.order(:number).group_by(&:size))
  end

  def suites_update_params
    params.require(:draw_suites_update).permit(suite_edit_param_hash)
  end

  def set_draw
    @draw = Draw.includes(:suites).find(params[:draw_id])
  end
end
