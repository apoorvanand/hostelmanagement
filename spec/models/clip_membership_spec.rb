# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ClipMembership, type: :model do
  describe 'basic validations' do
    it { is_expected.to belong_to(:group) }
    it { is_expected.to belong_to(:clip) }
    it { is_expected.to validate_presence_of(:group) }
    it { is_expected.to validate_presence_of(:clip) }
  end

  describe 'group uniqueness' do
    it 'is scoped to clip' do
      clip = FactoryGirl.create(:clip)
      membership = ClipMembership.new(clip: clip, group: clip.groups.first)
      expect(membership).not_to be_valid
    end
  end

  describe 'user can only have one accepted membership' do
    it do
      clip, other_clip = FactoryGirl.create_pair(:clip)
      m = ClipMembership.new(clip: other_clip, group: clip.groups.first)
      expect(m).not_to be_valid
    end
  end

  describe 'group draw and user draw must match' do
    it do
      clip = FactoryGirl.create(:clip)
      group = FactoryGirl.create(:group)
      membership = FactoryGirl.build(:clip_membership, clip: clip, group: group)
      expect(membership.valid?).to be_falsey
    end
  end

  describe 'cannot change clip' do
    it do
      clip = FactoryGirl.create(:clip)
      membership = clip.clip_memberships.last
      membership.clip = FactoryGirl.create(:clip, draw: clip.draw)
      expect(membership.save).to be_falsey
    end
  end

  describe 'cannot change group' do
    it do
      clip = FactoryGirl.create(:clip)
      membership = clip.clip_memberships.last
      membership.group = FactoryGirl.create(:group_from_draw, draw: clip.draw)
      expect(membership.save).to be_falsey
    end
  end

  describe 'cannot change associations' do
    it 'cannot change clip' do
      clip = FactoryGirl.create(:clip)
      membership = clip.clip_memberships.last
      membership.clip_id = nil
      expect(membership.save).to be_falsey
    end
    it 'cannot change group' do
      clip = FactoryGirl.create(:clip)
      membership = clip.clip_memberships.last
      membership.group_id = nil
      expect(membership.save).to be_falsey
    end
  end

  describe 'email callbacks' do
    let(:msg) { instance_spy(ActionMailer::MessageDelivery, deliver_later: 1) }

    it 'emails invitation on creation' do
      allow(StudentMailer).to receive(:invited_to_clip).and_return(msg)
      clip = FactoryGirl.create(:clip)
      group = FactoryGirl.create(:group_from_draw, draw: clip.draw)
      FactoryGirl.create(:clip_membership, clip: clip, group: group)
      expect(StudentMailer).to have_received(:invited_to_clip)
    end

    # rubocop:disable RSpec/ExampleLength
    it 'emails groups on invitation acceptance' do
      clip = FactoryGirl.create(:clip)
      group = FactoryGirl.create(:group_from_draw, draw: clip.draw)
      m = FactoryGirl.create(:clip_membership, clip: clip, group: group)
      allow(StudentMailer).to receive(:joined_clip).and_return(msg)
      m.update(confirmed: true)
      expect(StudentMailer).to have_received(:joined_clip)
    end # rubocop:enable RSpec/ExampleLength

    it 'emails groups when someone leaves' do
      clip = FactoryGirl.create(:clip, groups_count: 3)
      m = clip.clip_memberships.last
      allow(StudentMailer).to receive(:left_clip).and_return(msg)
      m.destroy
      expect(StudentMailer).to have_received(:left_clip)
    end
  end

  describe 'pending membership destruction' do
    context 'on the user creating their own group' do
      it do
        inv_clip = FactoryGirl.create(:clip)
        g, g2 = FactoryGirl.create_pair(:group_from_draw, draw: inv_clip.draw)
        invite = create_membership(clip: inv_clip, group: g)
        FactoryGirl.create(:clip, draw: g.draw, groups: [g, g2])
        expect { invite.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
    context 'on the user accepting another membership' do
      it do # rubocop:disable RSpec/ExampleLength
        group = FactoryGirl.create(:group)
        clip1, clip2 = FactoryGirl.create_pair(:clip, draw: group.draw)
        inv = create_membership(clip: clip1, group: group, confirmed: false)
        req = create_membership(clip: clip2, group: group, confirmed: false)
        inv.update(confirmed: true)
        expect { req.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end # rubocop:enable RSpec/ExampleLength
    end
    def create_membership(clip:, group:, confirmed: true)
      FactoryGirl.create(:clip_membership, clip: clip, group: group,
                                           confirmed: confirmed)
    end
  end
end
