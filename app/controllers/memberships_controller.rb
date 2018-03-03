# frozen_string_literal: true

# Controller for Memberships
class MembershipsController < ApplicationController
  prepend_before_action :set_group
  prepend_before_action :set_membership,
                        only: %i(accept_request accept_invitation leave
                                 finalize_membership reject_pending)

  def request_to_join
    result = MembershipCreator.create!(group: @group, user: current_user,
                                       status: 'requested')
    handle_action(path: draw_group_path(@draw, @group), **result)
  end

  def accept_request
    result = MembershipUpdater.update(membership: @membership,
                                      params: { status: 'accepted' })
    handle_action(path: draw_group_path(@draw, @group), **result)
  end

  def invite
    @students = UngroupedStudentsQuery.new(@draw.students.on_campus).call
  end

  def send_invites
    batch_params = { user_ids: memberships_params['invitations'], group: @group,
                     status: 'invited' }
    results = MembershipBatchCreator.run(**batch_params)
    handle_action(path: draw_group_path(@draw, @group), **results)
  end

  def accept_invitation
    result = MembershipUpdater.update(membership: @membership,
                                      params: { status: 'accepted' })
    handle_action(path: draw_group_path(@draw, @group), **result)
  end

  def reject_pending
    result = MembershipDestroyer.destroy(membership: @membership)
    handle_action(path: draw_group_path(@draw, @group), **result)
  end

  def leave
    result = MembershipDestroyer.destroy(membership: @membership)
    handle_action(path: draw_group_path(@draw, @group), **result)
  end

  def finalize_membership
    result = MembershipUpdater.update(membership: @membership,
                                      params: { locked: true })
    handle_action(path: draw_group_path(@draw, @group), **result)
  end

  private

  def authorize!
    if @membership
      authorize @membership
    else
      authorize Membership.new(group: @group)
    end
  end

  def set_group
    @group = Group.find(params[:group_id])
    @draw = @group.draw
  end

  def set_membership
    @membership = Membership.find(params[:id])
  end

  def memberships_params
    params.require(:group).permit(invitations: [])
  end
end
