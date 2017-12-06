# frozen_string_literal: true

# Helper methods to generate HTTP response with statuses
module Response
  def json_response(object:, status: :ok)
    render json: object, status: status
  end
end
