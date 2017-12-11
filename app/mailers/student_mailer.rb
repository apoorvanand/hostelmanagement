# frozen_string_literal: true

# Mailer class for student e-mails
class StudentMailer < ApplicationMailer
  # Send initial invitation to students in a draw
  #
  # @param user [User] the user to send the invitation to
  # @param college [College] the college to pull settings from
  def draw_invitation(user:, college: nil)
    determine_college(college)
    @user = user
    @intent_locked = user.draw.intent_locked
    @intent_deadline = format_date(user.draw.intent_deadline)
    mail(to: @user.email, subject: 'The housing process has begun')
  end

  # Send invitation to a group leader to select a suite
  #
  # @param user [User] the group leader to send the invitation to
  # @param college [College] the college to pull settings from
  def selection_invite(user:, college: nil)
    determine_college(college)
    @user = user
    mail(to: @user.email, subject: 'Time to select a suite!')
  end

  # Send notification to a user that their group was deleted
  #
  # @param user [User] the group leader to send the notification to
  # @param college [College] the college to pull settings from
  def disband_notification(user:, college: nil)
    determine_college(college)
    @user = user
    mail(to: @user.email, subject: 'Your housing group has been disbanded')
  end

  # Send notification to a user that their group is finalizing
  #
  # @param user [User] the group leader to send the notification to
  # @param college [College] the college to pull settings from
  def finalizing_notification(user:, college: nil)
    return unless user.group
    determine_college(college)
    @user = user
    @finalizing_url = if user.group.draw
                        draw_group_url(user.draw, user.group)
                      else
                        group_url(user.group)
                      end
    mail(to: @user.email, subject: 'Confirm your housing group')
  end

  # Send notification to a leader that a user joined their group
  #
  # @param user [User] the group leader to send the notification to
  # @param college [College] the college to pull settings from
  def joined_group(joined:, group:, college: nil)
    determine_college(college)
    @user = group.leader
    @joined = joined
    mail(to: @user.email, subject: "#{joined.full_name} has joined your group")
  end

  # Send notification to a leader that a user left their group
  #
  # @param user [User] the group leader to send the notification to
  # @param college [College] the college to pull settings from
  def left_group(left:, group:, college: nil)
    determine_college(college)
    @user = group.leader
    @left = left
    mail(to: @user.email, subject: "#{left.full_name} has left your group")
  end

  # Send notification to a user that their group is locked
  #
  # @param user [User] the group leader to send the notification to
  # @param college [College] the college to pull settings from
  def group_locked(user:, college: nil)
    determine_college(college)
    @user = user
    mail(to: @user.email, subject: 'Your housing group is now locked')
  end

  # Send reminder to submit housing intent to a user
  #
  # @param user [User] the student to send the reminder to
  # @param college [College] the college to pull settings from
  def intent_reminder(user:, college: nil)
    determine_college(college)
    @user = user
    @intent_date = format_date(user.draw.intent_deadline)
    mail(to: @user.email, subject: 'Reminder to submit housing intent')
  end

  # Send reminder to lock housing group to a user
  #
  # @param user [User] the student to send the reminder to
  # @param college [College] the college to pull settings from
  def locking_reminder(user:, college: nil)
    determine_college(college)
    @user = user
    @locking_date = format_date(user.draw.locking_deadline)
    mail(to: @user.email, subject: 'Reminder to lock housing group')
  end

  def invited_to_clip(invited:, clip:, college: nil)
    determine_college(college)
    @user = invited.leader
    @clip = clip
    mail(to: @user.email, subject: 'Your group has been invited to a clip')
  end

  def joined_clip(joining_group:, group:, college: nil)
    determine_college(college)
    @user = group.leader
    @joining_leader = joining_group.leader
    mail(to: @user.email,
         subject: "#{@joining_leader.full_name}'s group has joined your clip")
  end

  def left_clip(leaving_group:, group:, college: nil)
    determine_college(college)
    @user = group.leader
    @leaving_leader = leaving_group.leader
    mail(to: @user.email,
         subject: "#{@leaving_leader.full_name}'s group has left your clip")
  end

  def clip_disband_notice(group:, college: nil)
    determine_college(college)
    @user = group.leader
    mail(to: @user.email, subject: 'Your clip has been disbanded')
  end

  private

  def determine_college(college)
    @college = college || College.first || College.new
  end

  def format_date(date)
    return false unless date
    date.strftime('%B %e')
  end
end
