# frozen_string_literal: true

# rubocop:disable RSpec/NestedGroups
require 'rails_helper'

RSpec.describe ClipMembershipPolicy do
  subject { described_class }

  let(:record) { FactoryGirl.build_stubbed(:clip_membership) }

  # @params user [User] a user with the role being tested
  shared_examples 'non-admin permissions' do
    permissions :update?, :destroy? do
      let(:group) { instance_spy('Group', present?: true) }

      context 'not in a group' do
        before { allow(user).to receive(:group).and_return(nil) }
        it { is_expected.not_to permit(user, record) }
      end
      context 'in a group' do
        before { allow(user).to receive(:group).and_return(group) }

        context 'but does not lead the group' do
          before { allow(group).to receive(:leader).and_return(nil) }
          it { is_expected.not_to permit(user, record) }
        end
        context 'and leads it' do
          before { allow(group).to receive(:leader).and_return(user) }

          context 'but the invite is not for this group' do
            before do
              allow(record).to receive(:group).and_return(instance_spy('Group'))
            end
            it { is_expected.not_to permit(user, record) }
          end

          context 'with the correct invite' do
            before { allow(record).to receive(:group).and_return(group) }
            it { is_expected.to permit(user, record) }
          end
        end
      end
    end

    permissions :accept?, :reject? do
      let(:group) { instance_spy('Group', present?: true) }

      context 'not in a group' do
        before { allow(user).to receive(:group).and_return(nil) }
        it { is_expected.not_to permit(user, record) }
      end
      context 'in a group' do
        before { allow(user).to receive(:group).and_return(group) }

        context 'but does not lead the group' do
          before { allow(group).to receive(:leader).and_return(nil) }
          it { is_expected.not_to permit(user, record) }
        end
        context 'and leads it' do
          before { allow(group).to receive(:leader).and_return(user) }

          context 'but the invite is not for this group' do
            before do
              allow(record).to receive(:group).and_return(instance_spy('Group'))
            end
            it { is_expected.not_to permit(user, record) }
          end

          context 'with the correct invite' do
            before { allow(record).to receive(:group).and_return(group) }

            context 'but the membership is already confirmed' do
              before { allow(record).to receive(:confirmed).and_return(true) }
              it { is_expected.not_to permit(user, record) }
            end
            context 'and the membership is not confirmed' do
              before { allow(record).to receive(:confirmed).and_return(false) }
              it { is_expected.to permit(user, record) }
            end
          end
        end
      end
    end

    permissions :leave? do
      let(:group) { instance_spy('Group', present?: true) }

      context 'not in a group' do
        before { allow(user).to receive(:group).and_return(nil) }
        it { is_expected.not_to permit(user, record) }
      end
      context 'in a group' do
        before { allow(user).to receive(:group).and_return(group) }

        context 'but does not lead the group' do
          before { allow(group).to receive(:leader).and_return(nil) }
          it { is_expected.not_to permit(user, record) }
        end
        context 'and leads it' do
          before { allow(group).to receive(:leader).and_return(user) }

          context 'but the invite is not for this group' do
            before do
              allow(record).to receive(:group).and_return(instance_spy('Group'))
            end
            it { is_expected.not_to permit(user, record) }
          end

          context 'with the correct invite' do
            before { allow(record).to receive(:group).and_return(group) }

            context 'but the membership is not confirmed' do
              before { allow(record).to receive(:confirmed).and_return(false) }
              it { is_expected.not_to permit(user, record) }
            end
            context 'and the membership is confirmed' do
              before { allow(record).to receive(:confirmed).and_return(true) }
              it { is_expected.to permit(user, record) }
            end
          end
        end
      end
    end
  end

  context 'student' do
    it_behaves_like 'non-admin permissions' do
      let(:user) { FactoryGirl.build_stubbed(:user, role: 'student') }
    end
  end

  context 'housing rep' do
    it_behaves_like 'non-admin permissions' do
      let(:user) { FactoryGirl.build_stubbed(:user, role: 'rep') }
    end
  end

  context 'admin' do
    let(:user) { FactoryGirl.build_stubbed(:user, role: 'admin') }

    permissions :update?, :destroy?, :accept?, :reject?, :leave? do
      it { is_expected.not_to permit(user, record) }
    end
  end
end
