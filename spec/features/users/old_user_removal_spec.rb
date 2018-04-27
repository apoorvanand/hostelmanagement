# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Old user removal' do
  before { log_in FactoryGirl.create(:admin) }
  let(:room) { FactoryGirl.create(:room) }

  it 'removes user in room' do
    user = FactoryGirl.create(:user, room_id: room.id)
    msg = 'Successfully removed 1 records'
    visit users_path
    click_on "remove-students-#{user.class_year}"
    expect(page).to have_content(msg)
  end

  it 'keeps user in different year' do
    user = FactoryGirl.create(:user, room_id: room.id)
    user_next_year = FactoryGirl.create(:user, room_id: room.id, class_year: 1)
    visit users_path
    click_on "remove-students-#{user.class_year}"
    expect(User.where(id: user_next_year.id)).to exist
  end

  it 'keeps user not in room' do
    user = FactoryGirl.create(:user)
    visit users_path
    click_on "remove-students-#{user.class_year}"
    expect(User.where(id: user.id)).to exist
  end
end
