# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Suite Selection' do
  context 'user mode' do
    let(:leader) do
      create(:draw_in_selection,
             suite_selection_mode: 'student_selection').next_groups.first.leader
    end

    it 'can be performed by group leaders' do
      suite = leader.draw.suites.where(size: leader.group.size).first
      log_in leader
      select_suite(suite.number, leader.group.id)
      expect(page).to have_content('Suite assignment successful')
    end

    def select_suite(number, group_id)
      click_on 'Select Suite'
      select number, from: "suite_assignment_suite_id_for_#{group_id}"
      click_on 'Assign suites'
    end

    context 'admins can assign from group#show' do
      it 'only if the group is next' do
        log_in(FactoryGirl.create(:admin))
        suite = leader.draw.suites.where(size: leader.group.size).first
        visit draw_group_path(leader.draw, leader.group)
        admin_suite_assign(suite.number, leader.group.id)
        expect(page).to have_content('Suite assignment successful')
      end

      def admin_suite_assign(number, group_id)
        click_on 'Assign Suites'
        select number, from: "suite_assignment_suite_id_for_#{group_id}"
        click_button 'Assign suites'
      end
    end
  end

  context 'draw not in suite selection' do
    let(:group) do
      FactoryGirl.create(:open_group)
    end

    it 'link does not show' do
      log_in group.leader
      expect(page).not_to have_content('Select Suite')
    end

    it 'cannot reach page' do
      log_in group.leader
      visit new_group_suite_assignment_path(group)
      expect(page).to have_content("don't have permission")
    end
  end

  context 'admin mode' do
    let(:leader) do
      FactoryGirl.create(:draw_in_selection,
                         suite_selection_mode: 'admin_selection')
                 .next_groups.first.leader
    end

    it 'link does not show in student selection' do
      log_in leader
      expect(page).not_to have_content('Select Suite')
    end

    it 'cannot reach page from student selection' do
      log_in leader
      visit new_group_suite_assignment_path(leader.group)
      expect(page).to have_content("don't have permission")
    end
  end
end
