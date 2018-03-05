# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FavoritePolicy do
  subject { described_class }

  context 'student' do
    let(:group) { FactoryGirl.create(:full_group, size: 2) }
    let(:suite) { FactoryGirl.create(:suite_with_rooms, rooms_count: 2) }

    before do
      group.draw.suites << suite
    end

    permissions :show?, :create?, :new?, :edit?, :delete? do
      let(:fave) { FactoryGirl.create(:favorite, group: group, suite: suite) }

      context 'non-full group' do
        before { allow(group).to receive(:finalizing?).and_return(false) }
        it { is_expected.not_to permit(group, suite) }
      end
      context 'full group' do
        before { allow(group).to receive(:finalizing?).and_return(true) }
        it { is_expected.to permit(group, suite) }
      end
    end
  end
end
