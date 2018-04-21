# frozen_string_literal: true

# User destroy class that destroys all old users in a given year
#   Definition of 'old user': Any user that has already been assigned
#   a room accross any housing draw
class UserBulkDestroyer
  include Callable

  # Create a UserBulkDestroyer
  #
  # @param [Array] users The users to be deleted
  def initialize(users:)
    @users = users
  end

  # Use UserBulkDestroyer to attempt to destroy multiple users at one time
  #
  # @return [Hash{Symbol=>ApplicationRecord,Hash}]
  #   A results hash with a message to set in the flash and `nil`
  #   object
  def bulk_destroy
    @results = @users.map do |user|
      remove_group user
      Destroyer.new(object: user, name_method: :full_name).destroy
    end

    build_results
  end

  make_callable :bulk_destroy

  private

  attr_reader :users, :results, :successes, :failures

  def remove_group(user)
    return unless !user.group.nil? && user.led_group.nil?
    user.group.remove_members!(ids: [user.id])
  end

  def build_results
    @failures, @successes = @results.partition { |r| r[:msg].key? :error }
    { redirect_object: nil, msg: build_msg }
  end

  def build_msg
    if @failures.empty?
      { notice: success_msg }
    elsif @successes.empty?
      { notice: error_msg }
    else
      { notice: "Some errors have occured.\n" + success_msg + "\n" + error_msg }
    end
  end

  def success_msg
    if @successes.empty?
      'No users deleted'
    else
      "Successfully Deleted: #{@successes
                                 .map { |s| s[:msg][:notice] }.join(' ')}"
    end
  end

  def error_msg
    return if @failures.empty?
    "Unexpected Failure: #{@failures.map { |f| f[:msg][:error] }.join(' ')}"
  end
end
