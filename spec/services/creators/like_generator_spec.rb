# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LikeGenerator do
  context 'sucess' do
    it 'successfully creates a like' do
      params = instance_spy('ActionController::Parameters', to_h: params_hash)
      expect(described_class.create(params: params)[:redirect_object]).to \
        be_instance_of(Like)
    end
  end

  def params_hash
    group = FactoryGirl.create(:open_group, size: 2)
    user = FactoryGirl.create(:student, intent: 'on_campus', draw: group.draw)
    suite = FactoryGirl.create(:suite_with_rooms, rooms_count: 2)
    ensure_valid(group: group, user: user, suite: suite)
    favorite = FactoryGirl.create(:favorite, group: group, suite: suite)
    { favorite: favorite, user: user }
  end

  def ensure_valid(group:, user:, suite:)
    group.members << user
    group.draw.suites << suite
  end
end
