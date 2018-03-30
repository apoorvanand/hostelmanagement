# frozen_string_literal: true

require 'rails_helper'

RSpec.feature "Old user removal" do 
	before { log_in FactoryGirl.create(:admin) }
	let!(:user) { FactoryGirl.create(:user) }
	let(:room) { FactoryGirl.create(:room) }
	let!(:user_in_room) { FactoryGirl.create(:user, room_id: room.id) }
	let(:year) { Time.zone.today.year }
	let!(:user_next_year_in_room) { FactoryGirl.create(:user, class_year: (year+1), room_id: room.id) }

	it "removes user in room and year as specified" do
		msg = "All old users in #{year} are removed"

		visit users_path

		expect(page).to have_content("Students (3 total)")

		find("#students-#{year}").click
		click_on "remove-students-#{year}"

		expect(page).to have_content(msg)
		expect(page).to have_content("Students (2 total)")
	end
end