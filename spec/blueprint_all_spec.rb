# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Blueprint' do
	before { log_in FactoryGirl.create(:admin) }

  it 'exists' do
    visit blueprints_path
  end

  it 'creates' do
  	params = { building: "New Building", name: "New Name ZZA",
  	           size: "10", rooms: [1, 2, 4, 3] }

  	blueprint = Blueprint.create(params)
  	visit blueprint_path(blueprint.id)
  	expect(page).to have_content("New Name ZZA")

  	visit blueprints_path
  	expect(page).to have_content(blueprint.blueprint_name)
  end

  it 'creates from page' do
  	visit new_blueprint_path
  	fill_in 'Name', with: "New Name"
  	fill_in 'Building', with: "New Building"
  	fill_in 'Size', with: 10
  	fill_in 'Rooms', with: '[1, 2, 3, 4]'

  	click_on 'Create'

  	visit blueprints_path
  	expect(page).to have_content('New Name')
  end

  it 'destroys' do
  	params = { building: "New Building", name: "New Name",
  	           size: "10", rooms: [1, 2, 4, 3] }

  	blueprint = Blueprint.create(params)
  	visit blueprint_path(blueprint.id)
  	click_on 'Delete'

  	visit blueprints_path
  	expect(page).to have_no_content(blueprint.blueprint_name)
  end

  it 'imports' do
  	room = instance_double('Room')
  	building = instance_double('Building')
  	new_suite = FactoryGirl.build_stubbed(:suite)
  	allow(room).to receive(:number).and_return('ROOM')
  	allow(building).to receive(:name).and_return('BUILDING 2321')
  	allow(new_suite).to receive(:building).and_return Building
  	allow(new_suite).to receive(:rooms).and_return [room, room, room]
  	allow(Suite).to receive(:all).and_return [new_suite]

  	visit import_blueprints_path

  	click_on 'Index'
  	expect(page).to have_content(new_suite.number)
 	end
end
