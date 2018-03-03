# frozen_string_literal: true

# Class for Membership permissions
class MembershipPolicy < ApplicationPolicy
  def request_to_join?
    user.group.blank? && draws_match?(user, record) &&
      record.group.draw.pre_lottery?
  end

  def invite?
    (user.leader_of?(record.group) || user_has_uber_permission?) &&
      record.group.open?
  end

  def send_invites?
    invite?
  end

  def accept_request?
    (user.leader_of?(record.group) && group_not_locking?(record.group)) ||
      user_has_uber_permission?
  end

  def reject_pending?
    accept_request?
  end

  def accept_invitation?
    user.group.blank? && user.memberships.include?(record)
  end

  def leave?
    group_is_not_locked_and_matches?(user, record) &&
      !user.leader_of?(record.group)
  end

  def finalize_membership?
    user.group == record.group && !record.group.locked_members.include?(user) &&
      record.group.finalizing?
  end

  class Scope < Scope # rubocop:disable Style/Documentation
    def resolve
      scope
    end
  end

  private

  def group_not_locking?(group)
    !group.finalizing? && !group.locked?
  end

  def draws_match?(user, record)
    user.draw.present? && (user.draw == record.group.draw)
  end

  def group_is_not_locked_and_matches?(user, record)
    user.group.present? && !user.group.locked? && user.group == record.group
  end
end
