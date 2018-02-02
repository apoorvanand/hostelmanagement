# frozen_string_literal: true

# Like Controller class
class UsersController < ApplicationController
  prepend_before_action :set_user

  def show; end

  def new; end

  def edit; end

  private

  def set_user
    @user = User.find(params[:id])
    @group = user.group
  end
end
