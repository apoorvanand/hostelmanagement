# frozen_string_literal: true

module Api
  module V1
    # API Users Controller class
    class UsersController < Api::V1::ApiController
      prepend_before_action :set_user

      def update_intent
        result = Updater.update(object: @user, name_method: :full_name,
                                params: user_params)
        handle_response(**result)
      end

      private

      def user_params
        params.require(:user).permit(:intent)
      end

      def authorize!
        if @user
          authorize @user
        else
          authorize User
        end
      end

      def set_user
        @user = User.find(params[:id])
      end
    end
  end
end
