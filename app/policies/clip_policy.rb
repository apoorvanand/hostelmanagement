# frozen_string_literal: true

# Class for Clip permissions
class ClipPolicy < ApplicationPolicy
  def assign_lottery?
    user_has_uber_permission?
  end

  class Scope < Scope # rubocop:disable Style/Documentation
    def resolve
      scope
    end
  end
end
