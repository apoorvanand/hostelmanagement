# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BulkDestroyer do
  describe '#bulk_destroy' do
    it 'successfully destroys a collection of Users' do
      stub_destroyer_returns [success]
      users = FactoryGirl.build_stubbed_list(:user, 4)
      described_class.new(objects: users, name_method: :full_name).bulk_destroy
      expect(Destroyer).to have_received(:destroy).exactly(4).times
    end

    it 'catches destroyer success' do
      stub_destroyer_returns [success]
      users = FactoryGirl.build_stubbed_list(:user, 2)
      result = described_class.new(objects: users, name_method: :full_name).bulk_destroy
      expect(result[:msg][:notice]).to include 'Successfully removed 2 records'
    end

    it 'catches destroyer error' do
      stub_destroyer_returns [error]
      users = FactoryGirl.build_stubbed_list(:user, 2)
      result = described_class.new(objects: users, name_method: :full_name).bulk_destroy
      expect(result[:msg][:notice]).to include 'Unable to remove 2 records'
    end

    it 'catches destroyer mixed success and error' do
      stub_destroyer_returns [success, error]
      users = FactoryGirl.build_stubbed_list(:user, 2)
      result = described_class.new(objects: users, name_method: :full_name).bulk_destroy
      expect(result[:msg][:notice]).to include 'Some errors have occured.'
    end
  end

  def success
    { redirect_object: nil, msg: { notice: '' } }
  end

  def error
    { redirect_object: nil, msg: { error: '' } }
  end

  def user_in_group
    group = FactoryGirl.create(:full_group)
    user = group.members[1]
    user.group = group
    user
  end

  def stub_destroyer_returns(procedure)
    allow(Destroyer).to receive(:new).and_return(Destroyer)
    allow(Destroyer).to receive(:destroy).and_return(*procedure)
  end
end
