# frozen_string_literal: true

#
# Service object to lock groups
class LikeGenerator < Creator
  include Callable

  # Initialize the favorite
  def initialize(params:)
    @params = params.to_h.transform_keys(&:to_sym)
    process_params
  end

  def create
    ActiveRecord::Base.transaction do
      @like = Like.new(**params)
      @like.save!
    end
    success
  rescue ActiveRecord::RecordInvalid => e
    error(e)
  end

  make_callable :create

  private

  attr_reader :klass, :params, :name_method, :like

  def process_params
    return unless params[:user]
    @params[:user] = current_user unless params[:user]
  end

  def success
    {
      redirect_object: like, record: like,
      msg: { success: 'Like created.' }
    }
  end

  def error(e)
    msg = ErrorHandler.format(error_object: e)
    {
      redirect_object: nil, record: like,
      msg: {
        error: "There was a problem creating the like: #{msg}. "\
        'Please check like validations.'
      }
    }
  end
end
