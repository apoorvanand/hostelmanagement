# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Like, type: :model do
  describe 'basic validations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:favorite) }
    it { is_expected.to validate_presence_of(:user) }
    it { is_expected.to validate_presence_of(:favorite) }
  end

  describe 'members can only like a suite once' do
    it do
      fave_like1_like2 = favorite_creator
      user = User.find(fave_like1_like2[1].user_id)
      expect do
        FactoryGirl.create(:like, user: user, favorite: fave_like1_like2[0])
      end.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  describe 'faves are deleted when all likes to it are deleted' do
    it 'if there are undeleted likes' do
      fave_like1_like2 = favorite_creator
      fave_like1_like2[1].destroy
      expect(fave_like1_like2[0].likes).to include(fave_like1_like2[2])
    end
    it 'if there are no undeleted likes' do
      fave_like1_like2 = favorite_creator
      fave_like1_like2[1].destroy
      fave_like1_like2[2].destroy
      expect { Favorite.find(fave_like1_like2[0].id) }.to \
        raise_error(ActiveRecord::RecordNotFound)
    end
  end
  def favorite_creator
    group = FactoryGirl.create(:open_group, size: 2)
    user1 = FactoryGirl.create(:student, intent: 'on_campus',
                                         draw: group.draw)
    group.members << user1
    suite = FactoryGirl.create(:suite_with_rooms, rooms_count: 2)
    group.draw.suites << suite
    fave = FactoryGirl.create(:favorite, group: group, suite: suite)
    like1 = FactoryGirl.create(:like, user: user1, favorite: fave)
    like2 = FactoryGirl.create(:like, user: group.leader, favorite: fave)
    [fave, like1, like2]
  end
end
