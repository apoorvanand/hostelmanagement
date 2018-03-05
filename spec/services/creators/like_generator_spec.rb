# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LikeGenerator do

  describe 'generator' do
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

    it 'creates the like' do
      favorite = FactoryGirl.create(:favorite, group: group, suite: suite)
      expect(LikeGenerator.create!(favorite: favorite, user: user)).to \
        eq(Like.new(user: user, favorite: favorite))
    end
  end
end