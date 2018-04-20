# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserBulkDestroyer do
  before do
    Destroyer = instance_double 'destroyer'
    allow(Destroyer).to receive(:new).and_return(Destroyer)
    allow(Destroyer).to receive(:destroy).and_return(success)
  end

  it 'successfully destroys a collection of Users' do
    users = FactoryGirl.build_stubbed_list(:user, 4)
    user_bulk_destroyer = described_class.new(users: users)
    user_bulk_destroyer.bulk_destroy
    expect(Destroyer).to have_received(:destroy).exactly(4).times
  end

  def success
    { redirect_object: nil, msg: { notice: '' } }
  end
end
