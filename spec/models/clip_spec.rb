# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Clip, type: :model do
  describe 'basic validations' do
    it { is_expected.to have_many(:groups) }
    it { is_expected.to belong_to(:draw) }
    xit { is_expected.to validate_presence_of(:draw) }
  end

  describe 'validations' do
    context 'on draw' do
      it 'fail when groups are not in the same draw' do
        group1 = FactoryGirl.create(:group)
        group2 = FactoryGirl.create(:group)
        clip = FactoryGirl.create(:clip, groups: [group1, group2])
        expect(clip.valid?).to be_falsey
      end
    end
    context 'on lottery number' do
      it 'fail when groups have different lottery numbers' do
        draw = FactoryGirl.create(:oversubscribed_draw, groups_count: 2)
        draw.groups.first.update!(lottery_number: 1)
        draw.groups.last.update!(lottery_number: 2)
        clip = FactoryGirl.create(:clip, groups: draw.groups)
        expect(clip.valid?).to be_falsey
      end
      it 'fail when groups with lottery numbers join those without' do
        draw = FactoryGirl.create(:oversubscribed_draw, groups_count: 2)
        draw.groups.first.update!(lottery_number: 1)
        clip = FactoryGirl.create(:clip, groups: draw.groups)
        expect(clip.valid?).to be_falsey
      end
    end
  end

  describe '#clip_cleanup' do
    context 'is called when groups are deleted' do
      it 'and deletes the clip when it has no more groups' do
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
  end

  describe 'method wrappers' do
    context 'allow for duck typing on all needed group methods' do
      xit 'works for #[insert_method_here]' do
      end
    end
  end
end
