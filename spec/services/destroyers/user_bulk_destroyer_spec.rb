#frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserBulkDestroyer do

  it 'is true' do
    isTrue = true
    expect(isTrue).to eq(true)
  end

  it 'successfully destroys a collection of Users' do
    users = FactoryGirl.build_stubbed_list(:user, 4)
    Destroyer = double :destroyer
    allow(Destroyer).to receive(:new).and_return(Destroyer)
    allow(Destroyer).to receive(:destroy).and_return({ redirect_object: nil, msg: { notice: ''} })
    userbulkdestroyer = described_class.new(users: users)
    userbulkdestroyer.bulk_destroy
    expect(Destroyer).to have_received(:destroy).exactly(4).times
  end

end