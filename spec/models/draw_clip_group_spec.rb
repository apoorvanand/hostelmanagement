# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DrawClipGroup, type: :model do
  describe 'basic validations' do
    it { is_expected.to belong_to(:draw) }
    it { is_expected.to belong_to(:clip) }
    it { is_expected.to belong_to(:group) }
  end

  describe `#to_obj` do
    it 'returns a clip if there is a clip in the row' do
      clip = FactoryGirl.build_stubbed(:clip)
      expect(described_class.new(clip: clip).to_obj).to eq(clip)
    end
    it 'returns a group if there is a group in the row' do
      group = FactoryGirl.build_stubbed(:group)
      expect(described_class.new(group: group).to_obj).to eq(group)
    end
  end
end
