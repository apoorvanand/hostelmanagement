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
    draw = create(:draw_with_members, students_count: 2)
    draw.students.each do |s|
      group = create(:group, size: 1, leader: s)
      suite = create(:suite_with_rooms, group: group, draws: [draw])
      create(:room_assignment, user: s, room: suite.reload.rooms.first)
    end
    draw.students.first.update(last_name: 'Last2')
    draw.students.last.update(last_name: 'Last1')
    User.joins(room_assignment: [room: :suite])
  end

  def export_headers
    described_class::EXPORT_HEADERS.map(&:to_s).join(',') + "\n"
  end
end
