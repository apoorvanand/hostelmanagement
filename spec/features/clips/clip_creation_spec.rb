# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Clip Creation' do
  # rubocop:disable ExampleLength
  xit 'succeeds' do
    invited_group = FactoryGirl.create(:locked_group,
                                       :defined_by_draw, draw: group.draw)
    log_in_leader
    click_on 'Create a clip with other groups'
    select(invited_group, from: 'groups')
    click_on 'Submit'
    expect(page).to have_css("Invited #{invited_group.leader}'s group to clip.")
  end
  # rubocop:enable ExampleLength

  def log_in_leader
    group = FactoryGirl.create(:locked_group)
    log_in group.leader
    visit draw_group_path(group.draw, group)
  end
end
