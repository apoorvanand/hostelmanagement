# frozen_string_literal: true

# Class for Blueprint permissions
class BlueprintPolicy < ApplicationPolicy
	def show?
		true
	end

	def index?
		true
	end

	def import?
		user.admin?
	end

	class Scope < Scope # rubocop:disable Style/Documentation
	  def resolve
	    scope
	  end
	end
end