# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Favorite, type: :model do
  describe 'basic validations' do
    subject { FactoryGirl.build(:favorite) }

    it { is_expected.to validate_presence_of(:group) }
    it { is_expected.to validate_presence_of(:suite) }
    it { is_expected.to belong_to(:group) }
    it { is_expected.to belong_to(:suite) }
  end

  describe 'group draw and suite draw must match' do
    it do
      suite = FactoryGirl.create(:suite)
      group = FactoryGirl.create(:open_group)
      favorite = FactoryGirl.build(:favorite, suite: suite, group: group)
      expect(favorite.valid?).to be_falsey
    end
  end

  describe 'group size and suite size must match' do
    it do
      group = FactoryGirl.create(:full_group, size: 2)
      suite = FactoryGirl.create(:suite_with_rooms, rooms_count: 1)
      group.draw.suites << suite
      favorite = FactoryGirl.build(:favorite, suite: suite, group: group)
      expect(favorite.valid?).to be_falsey
    end
  end

  describe 'suite must be available' do
    it do
      group = FactoryGirl.create(:group_with_suite, size: 2)
      suite = group.suite
      favorite = FactoryGirl.build(:favorite, suite: suite, group: group)
      expect(favorite.valid?).to be_falsey
    end
  end
end
