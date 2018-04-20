# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserBulkDestroyer do
  describe '#bulk_destroy' do
    it 'successfully destroys a collection of Users' do
      stub_destroyer
      users = FactoryGirl.build_stubbed_list(:user, 4)
      user_bulk_destroyer = described_class.new(users: users)
      user_bulk_destroyer.bulk_destroy
      expect(Destroyer).to have_received(:destroy).exactly(4).times
    end

    it 'removes users from their groups' do
      user = user_in_group
      group_id = user.group.id;
      user_bulk_destroyer = described_class.new(users: [user])
      user_bulk_destroyer.bulk_destroy
      expect(Group.find(group_id).memberships.count).to eq(1)
    end
  end

  def success
    { redirect_object: nil, msg: { notice: '' } }
  end

  def user_in_group
    group = FactoryGirl.create(:full_group)
    user = group.members[1]
    user.group = group
    user
  end

  def stub_destroyer
    allow(Destroyer).to receive(:new).and_return(Destroyer)
    allow(Destroyer).to receive(:destroy).and_return(success)
  end
end
