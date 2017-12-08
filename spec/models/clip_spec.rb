# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Clip, type: :model do
  describe 'basic validations' do
    it { is_expected.to have_many(:groups) }
    it { is_expected.to belong_to(:draw) }
  end

  describe 'validations' do
    context 'on draw' do
      it 'fail when groups are not in the same draw' do
        groups = build_groups(count: 2, lottery_number: 1, draw_id: 1)
        groups.concat(build_groups(count: 1, lottery_number: 1, draw_id: 2))
        clip = described_class.new(draw_id: 1)
        allow(clip).to receive(:groups).and_return(groups)
        expect(clip).not_to be_valid
      end
      it 'pass when groups are all in the same draw' do
        groups = build_groups(count: 2, lottery_number: 1, draw_id: 1)
        clip = described_class.new(draw_id: 1)
        allow(clip).to receive(:groups).and_return(groups)
        expect(clip).to be_valid
      end
    end
    context 'on lottery number' do
      it 'fail when groups have different lottery numbers' do
        groups = build_groups(count: 2, lottery_number: 1, draw_id: 1)
        groups.concat(build_groups(count: 1, lottery_number: 2, draw_id: 1))
        clip = described_class.new(draw_id: 1)
        allow(clip).to receive(:groups).and_return(groups)
        expect(clip).not_to be_valid
      end
      it 'passes when groups have the same lottery numbers' do
        groups = build_groups(count: 2, lottery_number: 1, draw_id: 1)
        clip = described_class.new(draw_id: 1)
        allow(clip).to receive(:groups).and_return(groups)
        expect(clip).to be_valid
      end
    end
  end

  describe '#lottery_number' do
    it 'returns the lottery_number of the first group' do
      # Defaults to a lottery number of 1
      clip = FactoryGirl.build(:clip_with_lottery_numbers, groups_count: 2)
      expect(clip.lottery_number).to eq(1)
    end
  end

  describe '#lottery_number=' do
    it 'updates the lottery number of the groups' do
      # Defaults to a lottery number of 1
      clip = FactoryGirl.build(:clip_with_lottery_numbers, groups_count: 2)
      clip.lottery_number = 2
      expect(clip.groups.map(&:lottery_number)).to match_array([2, 2])
    end
  end

  describe '#name' do
    it 'displays the name' do
      clip = FactoryGirl.create(:clip, groups_count: 3)
      allow(clip.groups.first).to receive(:name).and_return('Test')
      expected = 'Test and 2 others'
      expect(clip.name).to eq(expected)
    end
  end

  describe 'groups association' do
    context 'only joins on confirmed memberships' do
      it 'successfully' do
        clip = FactoryGirl.create(:clip)
        expect(clip.groups.length).to eq(2)
      end
      it 'ignores unconfirmed memberships' do
        # Creates two memberships with a confirmed value of true
        clip = FactoryGirl.create(:clip)
        clip.clip_memberships.last.update!(confirmed: false)
        expect(clip.groups.reload.length).to eq(1)
      end
    end
  end

  def build_groups(count:, **overrides)
    group_params = Array.new(count) do |i|
      { name: "group#{i}", lottery_number: i + 1, draw_id: i + 1 }
        .merge(**overrides)
    end
    group_params.map { |p| instance_spy('group', **p) }
  end
end
