# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ResultsCSVGenerator do
  let!(:data) { create_data }

  describe 'sorting' do
    it 'sorts by suite' do
      result = described_class.generate(students: data, sort_by_suite: true)
      sorted = data.order(%w(suites.number rooms.number users.last_name))
      export = export_headers + sorted.map { |n| export_row_for(n) }.join
      expect(result).to eq(export)
    end

    it 'sorts by last name by default' do
      result = described_class.generate(students: data)
      sorted = data.order(:last_name)
      export = export_headers + sorted.map { |n| export_row_for(n) }.join
      expect(result).to eq(export)
    end
  end

  def export_row_for(student)
    [
      student.last_name, student.first_name, student.username,
      student.group&.suite&.number, student.room&.number
    ].join(',') + "\n"
  end

  def create_data # rubocop:disable AbcSize
    # Returns two students with last names 'Last1' and 'Last2' assigned to
    # different suites with 'Last2' assigned to a lower numbered suite
    # and 'Last1' to a higher numbered suite
    draw = FactoryGirl.create(:draw_with_members, students_count: 2)
    group1 = FactoryGirl.create(:group, size: 1, leader: draw.students.first)
    group2 = FactoryGirl.create(:group, size: 1, leader: draw.students.last)
    suite1 = FactoryGirl.create(:suite_with_rooms, group: group1, draws: [draw])
    suite2 = FactoryGirl.create(:suite_with_rooms, group: group2, draws: [draw])
    student1 = draw.students.first
    student2 = draw.students.last
    create(:room_assignment, user: student1, room: suite1.reload.rooms.first)
    create(:room_assignment, user: student2, room: suite2.reload.rooms.first)
    student1.update(last_name: 'Last2')
    student2.update(last_name: 'Last1')
    User.joins(room_assignment: [room: :suite])
  end

  def export_headers
    described_class::EXPORT_HEADERS.map(&:to_s).join(',') + "\n"
  end
end
