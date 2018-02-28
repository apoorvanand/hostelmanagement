require 'rails_helper'

RSpec.describe DrawProgressBar do
  describe '#intent' do
    it 'maps keys of #intent_metrics to symbols' do
      draw = instance_spy('DrawReport',
                          intent_metrics: { 's' => 1 }, student_count: 1)
      bar = DrawProgressBar.new(draw_report: draw)
      expect(bar.intent.keys).to \
        match_array(draw.intent_metrics.keys.map(&:to_sym))
    end

    it 'divides values of #intent_metrics by #student_count, as floats' do
      draw = instance_spy('DrawReport',
                          intent_metrics: { 's' => 2 }, student_count: 2)
      bar = DrawProgressBar.new(draw_report: draw)
      expect(bar.intent.values).to match_array([100.0])
    end

    it 'defaults to 0' do
      draw = instance_spy('DrawReport',
                          intent_metrics: { 's' => 2 }, student_count: 2)
      bar = DrawProgressBar.new(draw_report: draw)
      expect(bar.intent[:not_there]).to eq(0)
    end
  end

  describe '#group_formation' do
    let(:intent_hash) { { 'on_campus' => 2 } }
    let(:ungrouped_hash) do
      s = instance_spy('ActiveRecord::Associations::CollectionProxy', count: 1)
      { 'on_campus' => s }
    end

    it 'computes progress of on-campus students forming groups' do
      draw = instance_spy('DrawReport',
                          intent_metrics: intent_hash,
                          ungrouped_students: ungrouped_hash)
      bar = DrawProgressBar.new(draw_report: draw)
      expect(bar.group_formation).to eq({ in_groups: 50, not_in_groups: 50 })
    end

    it 'has values that sum to 100' do
      draw = instance_spy('DrawReport',
                          intent_metrics: intent_hash,
                          ungrouped_students: ungrouped_hash)
      bar = DrawProgressBar.new(draw_report: draw)
      expect(bar.group_formation.values.sum).to eq(100)
    end
  end

  describe '#group_formation_counts' do
    let(:intent_hash) { { 'on_campus' => 2 } }
    let(:ungrouped_hash) do
      s = instance_spy('ActiveRecord::Associations::CollectionProxy', count: 1)
      { 'on_campus' => s }
    end

    it 'computes progress of on-campus students forming groups' do
      draw = instance_spy('DrawReport',
                          intent_metrics: intent_hash,
                          ungrouped_students: ungrouped_hash)
      bar = DrawProgressBar.new(draw_report: draw)
      expect(bar.group_formation_counts).to \
        eq({ in_groups: 1, not_in_groups: 1 })
    end
  end

  describe '#suite_selection' do
    it 'returns a hash with the appropriate keys' do
      draw = instance_spy('DrawReport',
                          group_count: 2, groups_with_suites_count: 1,
                          groups_without_suites_count: 1)
      bar = DrawProgressBar.new(draw_report: draw)
      expect(bar.suite_selection.keys).to match_array(%i(with, without))
    end
    it 'divides the appropriate counts by group_count' do
      draw = instance_spy('DrawReport',
                          group_count: 2, groups_with_suites_count: 1,
                          groups_without_suites_count: 1)
      bar = DrawProgressBar.new(draw_report: draw)
      expect(bar.suite_selection.values).to match_array([50, 50])
    end
  end

  describe '#suite_selection_counts' do
  end
end
