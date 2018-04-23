# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Blueprint' do
	before { log_in FactoryGirl.create(:admin) }

  it 'exists' do
    visit blueprints_path
  end

  it 'creates' do
  	params = { building: "New Building", name: "New Name",
  	           size: "10", rooms: [1, 2, 4, 3] }

  	blueprint = Blueprint.create(params)
  	visit blueprint_path(blueprint.id)
  	expect(page).to have_content(blueprint.blueprint_name)
  end

end
