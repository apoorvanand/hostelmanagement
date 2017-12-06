# frozen_string_literal: true

module Api
  module V1
    # API Controller class that all other controllers inherit
    class ApiController < ActionController::Base
      include Pundit
      include Response
      include ExceptionHandler
      # Generic API stuff here
      # called before every action on controllers
      before_action :authenticate_user!, unless: :unauthenticated?
      before_action :check_college, unless: :devise_controller?
      before_action :authorize!, except: :home, unless: :unauthenticated?
      after_action :verify_authorized, except: :home, unless: :unauthenticated?
      protect_from_forgery with: :null_session

      rescue_from Pundit::NotAuthorizedError do |exception|
        Honeybadger.notify(exception)
        response = {
          data: {},
          msg: "Sorry, you don't have permission to do that."
        }
        json_response(object: response, status: :unauthorized)
      end

      private

      def unauthenticated?
        devise_controller? || self.class == HighVoltage::PagesController
      end

      def handle_response(redirect_object:, record: {}, msg:, **_)
        response = {}
        messages = {}
        msg.each { |flash_type, msg_str| messages[flash_type] = msg_str }
        status = redirect_object ? :ok : :internal_server_error
        response[:data] = record
        response[:msg] = messages
        json_response(object: response, status: status)
      end

      # Abstract method to enforce permissions authorization in all controllers.
      # Must be overridden in all controllers.
      #
      # @abstract
      def authorize!
        raise NoMethodError
      end

      def check_college
        return if current_college.persisted? || !policy(College).edit?
        flash[:warning] = 'You must update your college settings in order for '\
          'Vesta to function correctly'
      end

      def current_college
        @current_college ||= College.first || College.new
      end
    end
  end
end
