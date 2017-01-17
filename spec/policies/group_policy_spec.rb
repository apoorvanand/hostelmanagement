# frozen_string_literal: true
require 'rails_helper'

RSpec.describe GroupPolicy do
  subject { described_class }

  context 'student' do
    let(:user) { FactoryGirl.build_stubbed(:user, role: 'student') }
    let(:group) { FactoryGirl.build_stubbed(:group, leader: user) }
    let(:other_group) { FactoryGirl.build_stubbed(:group) }

    permissions :create? do
      context 'in draw, not in group' do
        before do
          allow(user).to receive(:draw).and_return(instance_spy('Draw'))
          allow(user).to receive(:group).and_return(nil)
        end
        it { is_expected.to permit(user, Group) }
      end
      context 'in draw, in group' do
        before do
          allow(user).to receive(:draw).and_return(instance_spy('Draw'))
          allow(user).to receive(:group).and_return(instance_spy('Group'))
        end
        it { is_expected.not_to permit(user, Group) }
      end
      context 'not in draw' do
        it { is_expected.not_to permit(user, Group) }
      end
    end
    permissions :index? do
      it { is_expected.to permit(user, [group, other_group]) }
    end
    permissions :show? do
      it { is_expected.to permit(user, group) }
      it { is_expected.to permit(user, other_group) }
    end
    permissions :destroy?, :edit?, :update? do
      it { is_expected.to permit(user, group) }
      it { is_expected.not_to permit(user, other_group) }
    end
  end

  context 'housing rep' do
    let(:user) { FactoryGirl.build_stubbed(:user, role: 'rep') }
    let(:group) { FactoryGirl.build_stubbed(:group, leader: user) }
    let(:other_group) { FactoryGirl.build_stubbed(:group) }

    permissions :create? do
      context 'in draw, not in group' do
        before do
          allow(user).to receive(:draw).and_return(instance_spy('Draw'))
          allow(user).to receive(:group).and_return(nil)
        end
        it { is_expected.to permit(user, Group) }
      end
      context 'in draw, in group' do
        before do
          allow(user).to receive(:draw).and_return(instance_spy('Draw'))
          allow(user).to receive(:group).and_return(instance_spy('Group'))
        end
        it { is_expected.not_to permit(user, Group) }
      end
      context 'not in draw' do
        it { is_expected.not_to permit(user, Group) }
      end
    end
    permissions :index? do
      it { is_expected.to permit(user, [group, other_group]) }
    end
    permissions :show? do
      it { is_expected.to permit(user, group) }
      it { is_expected.to permit(user, other_group) }
    end
    permissions :destroy?, :edit?, :update? do
      it { is_expected.to permit(user, group) }
      it { is_expected.not_to permit(user, other_group) }
    end
  end

  context 'admin' do
    let(:user) { FactoryGirl.build_stubbed(:user, role: 'admin') }
    let(:group) { FactoryGirl.build_stubbed(:group) }

    permissions :create? do
      it { is_expected.to permit(user, Group) }
    end
    permissions :index? do
      it { is_expected.to permit(user, [group]) }
    end
    permissions :show?, :edit?, :update?, :destroy? do
      it { is_expected.to permit(user, group) }
    end
  end
end