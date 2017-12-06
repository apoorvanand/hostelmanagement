# frozen_string_literal: true

# Helps handle exceptions from API calls with missing records
module ExceptionHandler
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordNotFound do |e|
      json_response(object: { msg: e.message }, status: :not_found)
    end

    rescue_from ActiveRecord::RecordInvalid do |e|
      json_response(object: { msg: e.message }, status: :not_found)
    end
  end
end
