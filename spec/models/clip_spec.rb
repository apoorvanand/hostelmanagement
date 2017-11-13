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
        draw = FactoryGirl.create(:draw_with_groups, groups_count: 1)
        group1 = draw.groups.first
        group2 = FactoryGirl.build(:group)
        result = FactoryGirl.build(:clip, groups: [group1, group2], draw: draw)
        expect(result).not_to be_valid
      end
    end
    context 'on lottery number' do
      it 'fail when groups have different lottery numbers' do
        draw = FactoryGirl.create(:draw_with_groups, groups_count: 2)
        draw.groups.first.update!(lottery_number: 1)
        draw.groups.last.update!(lottery_number: 2)
        result = FactoryGirl.build(:clip, draw: draw)
        expect(result).not_to be_valid
      end
      it 'fail when groups with lottery numbers join those without' do
        draw = FactoryGirl.create(:draw_with_groups, groups_count: 2)
        draw.groups.first.update!(lottery_number: 1)
        result = FactoryGirl.build(:clip, draw: draw)
        expect(result).not_to be_valid
      end
      it 'passes when groups have the same lottery numbers' do
        draw = FactoryGirl.create(:draw_with_groups, groups_count: 2)
        draw.groups.first.update!(lottery_number: 1)
        draw.groups.last.update!(lottery_number: 1)
        # draw = instance_spy('draw', draw_id: 1, name: 'draw')
        # draw = FactoryGirl.build(:draw)
        # groups = build_groups(count: 2, draw_id: draw.id)
        # result = Clip.new(draw: draw, groups: groups)
        result = FactoryGirl.build(:clip, draw: draw)
        expect(result).to be_valid
      end
    end
    context 'groups' do
      it 'clear clip assignments on clip destruction' do
        draw = FactoryGirl.create(:draw_with_groups, groups_count: 2)
        group = draw.groups.first
        clip = FactoryGirl.create(:clip, draw: draw)
        expect { clip.destroy }.to change { group.reload.clip }.to(nil)
      end
    end
  end

  describe '#clip_cleanup' do
    context 'is called when groups are deleted' do
      it 'and deletes the clip if there are not enough groups left' do
        clip = FactoryGirl.create(:clip, groups_count: 2)
        clip.groups.first.destroy!
        expect(clip.persisted?).to be_falsey
      end

      it 'does nothing if there are more groups left' do
        clip = FactoryGirl.create(:clip, groups_count: 3)
        clip.groups.first.destroy!
        expect(clip.persisted?).to be_truthy
      end
    end
    context 'is called if a draw in a group is changed' do
      it 'and deletes the clip if there are not enough groups left' do
        clip = FactoryGirl.create(:clip, groups_count: 2)
        clip.groups.first.update!(draw_id: nil)
        expect(clip.persisted?).to be_falsey
      end
      it 'does nothing if there are more groups left' do
        clip = FactoryGirl.create(:clip, groups_count: 3)
        clip.groups.first.update!(draw_id: nil)
        expect(clip.persisted?).to be_truthy
      end
    end
  end

  describe '#name' do
    it 'displays the name' do
      clip = FactoryGirl.build_stubbed(:clip, groups_count: 3)
      allow(clip.groups.first).to receive(:name).and_return('Test')
      expected = 'Test and 2 others'
      expect(clip.name).to eq(expected)
    end
  end

  describe 'method wrappers' do
    context 'allow for duck typing on all needed group methods' do
      xit 'works for #[insert_method_here]' do
      end
    end
  end
  def build_groups(count:, **overrides)
    Array.new(count) do |i|
      instance_spy('group', name: "group#{i}", lottery_number: 1,
                            draw_id: 1).merge(**overrides)
    end
  end
end
