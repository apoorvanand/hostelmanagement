# frozen_string_literal: true

# rubocop:disable RSpec/NestedGroups

require 'rails_helper'

RSpec.describe MembershipPolicy do
  subject { described_class }

  let(:membership) { build_stubbed(:membership) }
  let(:group) { instance_spy('group', blank?: false) }
  let(:draw) { instance_spy('draw', present?: true) }

  context 'student' do
    let(:user) { build_stubbed(:user, role: 'student') }

    permissions :request_to_join? do
      context 'already has a group' do
        before { allow(user).to receive(:group).and_return(group) }

        it { is_expected.not_to permit(user, membership) }
      end

      context 'has no group' do
        before do
          allow(user).to receive(:group).and_return(nil)
          allow(membership).to receive(:group).and_return(group)
        end

        context 'but has no draw' do
          before { allow(user).to receive(:draw).and_return(nil) }

          it { is_expected.not_to permit(user, membership) }
        end

        context 'and has a draw' do
          before { allow(user).to receive(:draw).and_return(draw) }

          context 'but draws do not match' do
            let(:other_draw) { build_stubbed(:draw) }

            before { allow(group).to receive(:draw).and_return(other_draw) }

            it { is_expected.not_to permit(user, membership) }
          end

          context 'and draws match' do
            before { allow(group).to receive(:draw).and_return(draw) }

            context 'but draw is not pre-lottery' do
              before { allow(draw).to receive(:pre_lottery?).and_return(false) }

              it { is_expected.not_to permit(user, membership) }
            end

            context 'and draw is pre-lottery' do
              before { allow(draw).to receive(:pre_lottery?).and_return(true) }

              it { is_expected.to permit(user, membership) }
            end
          end
        end
      end
    end

    permissions :invite?, :send_invites? do
      context 'not the leader of the group' do
        before do
          allow(membership).to receive(:group).and_return(group)
          allow(user).to receive(:leader_of?).with(group).and_return(false)
        end

        it { is_expected.not_to permit(user, membership) }
      end

      context 'and is the leader of the group' do
        before do
          allow(membership).to receive(:group).and_return(group)
          allow(user).to receive(:leader_of?).with(group).and_return(true)
        end

        context 'but the group is not open' do
          before { allow(group).to receive(:open?).and_return(false) }

          it { is_expected.not_to permit(user, membership) }
        end

        context 'and the group is open' do
          before { allow(group).to receive(:open?).and_return(true) }

          it { is_expected.to permit(user, membership) }
        end
      end
    end

    permissions :accept_request?, :reject_pending? do
      before { allow(membership).to receive(:group).and_return(group) }

      context 'not the leader of the group' do
        before do
          allow(user).to receive(:leader_of?).with(group).and_return(false)
        end

        it { is_expected.not_to permit(user, membership) }
      end

      context 'and is the leader of the group' do
        before do
          allow(user).to receive(:leader_of?).with(group).and_return(true)
        end

        context 'but the group is finalizing' do
          before { allow(group).to receive(:finalizing?).and_return(true) }

          it { is_expected.not_to permit(user, membership) }
        end

        context 'and the group is not finalizing' do
          before { allow(group).to receive(:finalizing?).and_return(false) }

          context 'but the group is locked' do
            before { allow(group).to receive(:locked?).and_return(true) }

            it { is_expected.not_to permit(user, membership) }
          end

          context 'and the group is not locked' do
            before { allow(group).to receive(:locked?).and_return(false) }

            it { is_expected.to permit(user, membership) }
          end
        end
      end
    end

    permissions :accept_invitation? do
      context 'already has a group' do
        before { allow(user).to receive(:group).and_return(group) }

        it { is_expected.not_to permit(user, membership) }
      end

      context 'has no group' do
        let(:other_membership) { instance_spy('membership') }

        before { allow(user).to receive(:group).and_return(nil) }

        context 'but user has not been invited' do
          before do
            allow(user).to receive(:memberships).and_return([other_membership])
          end

          it { is_expected.not_to permit(user, membership) }
        end

        context 'and user has been invited' do
          before do
            memberships = [other_membership, membership]
            allow(user).to receive(:memberships).and_return(memberships)
          end

          it { is_expected.to permit(user, membership) }
        end
      end
    end

    permissions :leave? do
      context 'user has no group' do
        before { allow(user).to receive(:group).and_return(nil) }

        it { is_expected.not_to permit(user, membership) }
      end

      context 'user has a group' do
        before { allow(user).to receive(:group).and_return(group) }

        context 'but group is locked' do
          before { allow(group).to receive(:locked?).and_return(true) }

          it { is_expected.not_to permit(user, membership) }
        end

        context  'and the group is not locked' do
          before { allow(group).to receive(:locked?).and_return(false) }

          context 'but the user group and membership group do not match' do
            let(:other_group) { instance_spy('group') }

            before do
              allow(membership).to receive(:group).and_return(other_group)
            end

            it { is_expected.not_to permit(user, membership) }
          end

          context 'and the group is part of the membership' do
            before { allow(membership).to receive(:group).and_return(group) }

            context 'but the user is the leader of their group' do
              before do
                allow(user).to receive(:leader_of?).with(group).and_return(true)
              end

              it { is_expected.not_to permit(user, membership) }
            end

            context 'and the user is not the leader of their group' do
              before do
                allow(user).to receive(:leader_of?).with(group)
                                                   .and_return(false)
              end

              it { is_expected.to permit(user, membership) }
            end
          end
        end
      end
    end

    permissions :finalize_membership? do
      context 'groups do not match' do
        before do
          allow(membership).to receive(:group).and_return(group)
          allow(user).to receive(:group).and_return(nil)
        end

        it { is_expected.not_to permit(user, membership) }
      end

      context 'groups match' do
        before do
          allow(membership).to receive(:group).and_return(group)
          allow(user).to receive(:group).and_return(group)
        end

        context 'user has already locked their membership' do
          before { allow(group).to receive(:locked_members).and_return([user]) }

          it { is_expected.not_to permit(user, membership) }
        end

        context 'and the membership is unlocked' do
          before { allow(group).to receive(:locked_members).and_return([]) }

          context 'but the group is not finalizing' do
            before { allow(group).to receive(:finalizing?).and_return(false) }

            it { is_expected.not_to permit(user, membership) }
          end

          context 'and the group is finalizing' do
            before { allow(group).to receive(:finalizing?).and_return(true) }

            it { is_expected.to permit(user, membership) }
          end
        end
      end
    end
  end

  context 'rep' do
    let(:user) { build_stubbed(:user, role: 'rep') }

    permissions :request_to_join? do
      context 'already has a group' do
        before { allow(user).to receive(:group).and_return(group) }

        it { is_expected.not_to permit(user, membership) }
      end

      context 'has no group' do
        before do
          allow(user).to receive(:group).and_return(nil)
          allow(membership).to receive(:group).and_return(group)
        end

        context 'but has no draw' do
          before { allow(user).to receive(:draw).and_return(nil) }

          it { is_expected.not_to permit(user, membership) }
        end

        context 'and has a draw' do
          before { allow(user).to receive(:draw).and_return(draw) }

          context 'but draws do not match' do
            let(:other_draw) { build_stubbed(:draw) }

            before { allow(group).to receive(:draw).and_return(other_draw) }

            it { is_expected.not_to permit(user, membership) }
          end

          context 'and draws match' do
            before { allow(group).to receive(:draw).and_return(draw) }

            context 'but draw is not pre-lottery' do
              before { allow(draw).to receive(:pre_lottery?).and_return(false) }

              it { is_expected.not_to permit(user, membership) }
            end

            context 'and draw is pre-lottery' do
              before { allow(draw).to receive(:pre_lottery?).and_return(true) }

              it { is_expected.to permit(user, membership) }
            end
          end
        end
      end
    end

    permissions :invite?, :send_invites? do
      context 'the group is not open' do
        before do
          allow(group).to receive(:open?).and_return(false)
          allow(membership).to receive(:group).and_return(group)
        end

        it { is_expected.not_to permit(user, membership) }
      end

      context 'the group is open' do
        before do
          allow(group).to receive(:open?).and_return(true)
          allow(membership).to receive(:group).and_return(group)
        end

        it { is_expected.to permit(user, membership) }
      end
    end

    permissions :accept_request?, :reject_pending? do
      it { is_expected.to permit(user, membership) }
    end

    permissions :accept_invitation? do
      context 'already has a group' do
        before { allow(user).to receive(:group).and_return(group) }

        it { is_expected.not_to permit(user, membership) }
      end

      context 'has no group' do
        let(:other_membership) { instance_spy('membership') }

        before { allow(user).to receive(:group).and_return(nil) }

        context 'but user has not been invited' do
          before do
            allow(user).to receive(:memberships).and_return([other_membership])
          end

          it { is_expected.not_to permit(user, membership) }
        end

        context 'and user has been invited' do
          before do
            memberships = [other_membership, membership]
            allow(user).to receive(:memberships).and_return(memberships)
          end

          it { is_expected.to permit(user, membership) }
        end
      end
    end

    permissions :leave? do
      context 'user has no group' do
        before { allow(user).to receive(:group).and_return(nil) }

        it { is_expected.not_to permit(user, membership) }
      end

      context 'user has a group' do
        before { allow(user).to receive(:group).and_return(group) }

        context 'but group is locked' do
          before { allow(group).to receive(:locked?).and_return(true) }

          it { is_expected.not_to permit(user, membership) }
        end

        context  'and the group is not locked' do
          before { allow(group).to receive(:locked?).and_return(false) }

          context 'but the user group and membership group do not match' do
            let(:other_group) { instance_spy('group') }

            before do
              allow(membership).to receive(:group).and_return(other_group)
            end

            it { is_expected.not_to permit(user, membership) }
          end

          context 'and the group is part of the membership' do
            before { allow(membership).to receive(:group).and_return(group) }

            context 'but the user is the leader of their group' do
              before do
                allow(user).to receive(:leader_of?).with(group).and_return(true)
              end

              it { is_expected.not_to permit(user, membership) }
            end

            context 'and the user is not the leader of their group' do
              before do
                allow(user).to receive(:leader_of?).with(group)
                                                   .and_return(false)
              end

              it { is_expected.to permit(user, membership) }
            end
          end
        end
      end
    end

    permissions :finalize_membership? do
      before { allow(membership).to receive(:group).and_return(group) }

      context 'groups do not match' do
        before { allow(user).to receive(:group).and_return(nil) }

        it { is_expected.not_to permit(user, membership) }
      end

      context 'groups match' do
        before { allow(user).to receive(:group).and_return(group) }

        context 'user has already locked their membership' do
          before { allow(group).to receive(:locked_members).and_return([user]) }

          it { is_expected.not_to permit(user, membership) }
        end

        context 'and the membership is unlocked' do
          before { allow(group).to receive(:locked_members).and_return([]) }

          context 'but the group is not finalizing' do
            before { allow(group).to receive(:finalizing?).and_return(false) }

            it { is_expected.not_to permit(user, membership) }
          end

          context 'and the group is finalizing' do
            before { allow(group).to receive(:finalizing?).and_return(true) }

            it { is_expected.to permit(user, membership) }
          end
        end
      end
    end
  end

  context 'admin' do
    let(:user) { build_stubbed(:user, role: 'admin', draw: nil) }

    permissions :request_to_join?, :accept_invitation?, :leave?,
                :finalize_membership? do
      it { is_expected.not_to permit(user, membership) }
    end

    permissions :invite?, :send_invites? do
      before { allow(membership).to receive(:group).and_return(group) }

      context 'the group is not open' do
        before { allow(group).to receive(:open?).and_return(false) }

        it { is_expected.not_to permit(user, membership) }
      end

      context 'the group is open' do
        before { allow(group).to receive(:open?).and_return(true) }

        it { is_expected.to permit(user, membership) }
      end
    end

    permissions :accept_request?, :reject_pending? do
      it { is_expected.to permit(user, membership) }
    end
  end
end
