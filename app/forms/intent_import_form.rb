# frozen_string_literal: true

require 'csv'
require 'csv_reader'

# Form Object for Suite Importing
class IntentImportForm
  include ActiveModel::Model
  include Callable

  HEADER = %w(username intent).freeze

  # Initialize a new SuiteImporter and call #import on it
  #
  # @param [String] file The path to the CSV
  # @param [Building] building The building to put the suites in
  def initialize(file: nil, college:)
    college.activate!
    @file = file
    @successes = []
    @failures = []
  end

  # Import a set of suites from a CSV file. The file should have the header
  # "number,common,single,double,medical" where Number is the suite number and
  # Common, Single, and Double contain the room numbers for the rooms of that
  # size, separated by spaces. Medical suites are indicated by having any
  # content in the Medical column.
  #
  # @return [Hash{Symbol=>nil,Hash}] A hash with flash messages to be set.
  def import
    return error('No file uploaded') unless file
    @body = CSVReader.read(filename: file)
    return error('Header incorrect') unless correct_header?
    CSV.parse(@body.join("\n"), headers: true).each do |row|
      update_intent(row: row.to_hash.symbolize_keys)
    end
    result
  end

  make_callable :import

  private

  attr_accessor :successes, :failures
  attr_reader :body, :header, :string, :file

  def update_intent(row:)
    ActiveRecord::Base.transaction do
      User.find_by(username: row[:username]).update!(intent: row[:intent])
    end
    successes << row[:number]
  rescue ActiveRecord::RecordInvalid
    failures << row[:number]
  end

  def result
    { redirect_object: nil, msg: build_flash }
  end

  def build_flash
    if successes.empty?
      { error: failure_msg }
    elsif failures.empty?
      { success: success_msg }
    else
      { success: success_msg, error: failure_msg }
    end
  end

  def success_msg
    return nil if successes.empty?
    "Successfully updated intent for #{successes.size} students."
  end

  def failure_msg
    return nil if failures.empty?
    "Failed to update intents for the following rows: #{failures.join(', ')}."
  end

  def error(msg)
    { redirect_object: nil, msg: { error: msg } }
  end

  def correct_header?
    return true if @body.first.split(',') == HEADER
    false
  end
end
