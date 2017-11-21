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
      it 'fail when groups with lottery numbers join those without' do
        groups = build_groups(count: 2, lottery_number: 1, draw_id: 1)
        groups.concat(build_groups(count: 1, lottery_number: 2, draw_id: nil))
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
    context 'groups' do
      it 'clear clip assignments on clip destruction' do
        draw = FactoryGirl.create(:draw_with_groups, groups_count: 2)
        group = draw.groups.first
        # The clip factory currently assigns all groups in the draw to the clip.
        clip = FactoryGirl.create(:clip, draw: draw)
        expect { clip.destroy }.to change { group.reload.clip }.to(nil)
      end
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

  describe 'method wrappers' do
    context 'allow for duck typing on all needed group methods' do
      xit 'works for #[insert_method_here]' do
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
