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

  describe 'cannot change accepted status' do
    xit do
      group = FactoryGirl.create(:full_group)
      membership = group.memberships.last
      membership.status = 'requested'
      expect(membership.save).to be_falsey
    end
  end

  describe 'email callbacks' do
    let(:msg) { instance_spy(ActionMailer::MessageDelivery, deliver_later: 1) }

    # rubocop:disable RSpec/ExampleLength
    xit 'emails leader on invitation acceptance' do
      g = FactoryGirl.create(:open_group)
      m = Membership.create(user: FactoryGirl.create(:student, draw: g.draw),
                            group: g, status: 'invited')
      allow(StudentMailer).to receive(:joined_group).and_return(msg)
      m.update(status: 'accepted')
      expect(StudentMailer).to have_received(:joined_group)
    end
    # rubocop:enable RSpec/ExampleLength
    xit 'emails leader when someone leaves' do
      group = FactoryGirl.create(:full_group)
      m = group.memberships.last
      allow(StudentMailer).to receive(:left_group).and_return(msg)
      m.destroy
      expect(StudentMailer).to have_received(:left_group)
    end
  end

  describe 'pending membership destruction' do
    context 'on the user creating their own group' do
      xit do
        inv_group = FactoryGirl.create(:open_group, size: 2)
        u = FactoryGirl.create(:user, draw: inv_group.draw)
        invite = Membership.create(group: inv_group, user: u, status: 'invited')
        FactoryGirl.create(:group, leader: u)
        expect { invite.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
    context 'on the user accepting another membership' do
      xit do # rubocop:disable RSpec/ExampleLength
        inv_group = FactoryGirl.create(:open_group, size: 2)
        req_group = create_group_in_draw(inv_group.draw)
        u = FactoryGirl.create(:user, draw: inv_group.draw)
        inv = Membership.create(group: inv_group, user: u, status: 'invited')
        req = Membership.create(group: req_group, user: u, status: 'requested')
        inv.update(status: 'accepted')
        expect { req.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end

      def create_group_in_draw(draw)
        l = FactoryGirl.create(:user, draw: draw)
        FactoryGirl.create(:open_group, size: 2, leader: l)
      end
    end
  end
end
