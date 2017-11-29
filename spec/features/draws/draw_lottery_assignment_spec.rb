# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Draw lottery assignment', js: true do
  let!(:draw) { FactoryGirl.create(:draw_in_lottery, groups_count: 2) }
  let!(:group) { draw.groups.first }

  context 'as admin' do
    before { log_in FactoryGirl.create(:admin) }

    it 'can be performed' do
      visit draw_path(draw)
      click_on 'Assign lottery numbers'
      assign_lottery_number_to_group(group, 1)
      reload
      expect(lottery_number_saved_for_group?(page, group, 1)).to be_truthy
    end

    it 'can be removed' do
      group.update!(lottery_number: 2)
      visit lottery_draw_path(draw)
      assign_lottery_number_to_group(group, '')
      expect(group.reload.lottery_number).to be_nil
    end

    it 'can assign numbers to clips' do
      clip = create_clip
      visit lottery_draw_path(draw)
      assign_lottery_number_to_clip(clip, 1)
      reload
      expect(lottery_number_saved_for_clip?(page, clip, 1)).to be_truthy
    end

    def assign_lottery_number_to_group(group, number)
      within("\#lottery-form-#{group.id}") do
        fill_in 'group_lottery_number', with: number.to_s
        find(:css, '#group_lottery_number').send_keys(:tab)
      end
    end

    def assign_lottery_number_to_clip(clip, number)
      within("\#lottery-form-#{clip.id}") do
        fill_in 'clip_lottery_number', with: number.to_s
        find(:css, '#clip_lottery_number').send_keys(:tab)
      end
    end

    def reload
      page.evaluate_script('window.location.reload()')
    end

    def lottery_number_saved_for_group?(_page, group, number)
      within("\#lottery-form-#{group.id}") do
        assert_selector(:css, "#group_lottery_number[value='#{number}']")
      end
    end

    def lottery_number_saved_for_clip?(_page, clip, number)
      within("\#lottery-form-#{clip.id}") do
        assert_selector(:css, "#clip_lottery_number[value='#{number}']")
      end
    end

    def create_clip
      draw.groups.destroy_all
      FactoryGirl.create(:clip, draw: draw)
    end
  end

  context 'as rep' do
    before { log_in FactoryGirl.create(:user, role: 'rep') }

    it 'can view draw page with incomplete lottery' do
      group.update!(lottery_number: 1)
      visit draw_path(draw)
      expect(page).to have_content(draw.name)
    end
  end
end
