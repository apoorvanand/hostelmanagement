# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LikePolicy do
  subject { described_class }

  context 'student' do
    let(:group) { FactoryGirl.create(:open_group, size: 2) }
    let(:user) do
      FactoryGirl.create(:student, intent: 'on_campus',
                                   draw: group.draw)
    end
    let(:suite) { FactoryGirl.create(:suite_with_rooms, rooms_count: 2) }

    before do
      group.members << user
      group.draw.suites << suite
    end

    permissions :show?, :create?, :new?, :edit?, :delete? do
      let(:fave) { FactoryGirl.create(:favorite, group: group, suite: suite) }
      let(:like) { FactoryGirl.create(:like, user: user, favorite: fave) }

      context 'non-full group' do
        before do
          allow(group).to receive(:finalizing?).and_return(false)
          allow(user).to receive(:group).and_return(group)
        end
        it { is_expected.not_to permit(user, fave.suite) }
      end
      context 'full group' do
        before do
          allow(group).to receive(:finalizing?).and_return(true)
          allow(user).to receive(:group).and_return(group)
        end
        it { is_expected.to permit(user, fave.suite) }
      end
    end
  end

  context 'admin' do
    let(:user) { FactoryGirl.build_stubbed(:user, role: 'admin') }

    permissions :show?, :create?, :delete? do
      it { is_expected.not_to permit(user) }
    end
  end
end
