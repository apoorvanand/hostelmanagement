# frozen_string_literal: true

# Base controller class.
class ApplicationController < ActionController::Base
  include Pundit
  protect_from_forgery with: :exception
  before_action :authenticate_user!, unless: :unauthenticated?
  before_action :authorize_college, unless: :devise_controller?
  before_action :authorize!, except: :home, unless: :unauthenticated?
  after_action :verify_authorized, except: :home, unless: :unauthenticated?

  rescue_from Pundit::NotAuthorizedError do |exception|
    Honeybadger.notify(exception)
    flash[:error] = "Sorry, you don't have permission to do that."
    redirect_to request.referer.present? ? request.referer : root_path
  end

  def home; end

  private

  def unauthenticated?
    devise_controller? || self.class == HighVoltage::PagesController
  end

  # Abstract method to handle object CRUD. Handles success, failure,
  # and setting the flash appropriately.
  #
  # @abstract
  # @param [ApplicationRecord] object The object key from the service object
  #   results
  # @param [Hash{Symbol=>String}] msg The msg key from the service object
  #   results
  # @param [String] action The action to render when no object passed.
  #   (Creation / update failure, destruction success)
  # @param [String] path The path to redirect to when no object passed.
  def handle_action(redirect_object:, msg:, action: nil, path: nil, **_)
    msg.each { |flash_type, msg_str| flash[flash_type] = msg_str }
    redirect_to(redirect_object) && return if redirect_object
    complete_request(action: action, path: path)
  end

  def complete_request(action: nil, path: nil)
    if path
      redirect_to path
    elsif action
      render action: action
    else
      redirect_to root_path
    end
  end

  # Abstract method to enforce permissions authorization in all controllers.
  # Must be overridden in all controllers.
  #
  # @abstract
  def authorize!
    raise NoMethodError
  end

  def authorize_college
    # authorize current_college, :access?
    # return if current_college.persisted? || !policy(College).edit?
    # flash[:warning] = 'You must update your college settings in order for '\
    #   'Vesta to function correctly'
  end

  # Find and return the current college / tenant. Should redirect to the root
  # URL which should be some kind of tenant index eventually.
  #
  # @return [College] the current college
  def current_college
    @current_college ||= College.current
  rescue ActiveRecord::RecordNotFound
    redirect_to root_url(host: request.domain)
  end
end
