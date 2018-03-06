require 'rails_helper'

RSpec.feature 'User Intent Import' do
  before do
    2.times { |i| create(:student, username: "user#{i}") }
    log_in FactoryGirl.create(:admin)
  end
  it 'succeeds' do
    click_on 'All Users'
    save_and_open_page
    attach_file('intent_import_form[file]',
                Rails.root.join('spec', 'fixtures', 'intent_upload.csv'))
    click_on 'Upload Intents'
    expect(page).to have_css('.flash-success', text: /intent/)
  end
end
