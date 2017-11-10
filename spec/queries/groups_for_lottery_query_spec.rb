# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GroupsForLotteryQuery do
  context 'correctly' do
    it 'returns groups and clips in a draw' do
      draw = FactoryGirl.create(:draw)
      clip = FactoryGirl.create(:clip, draw: draw)
      group = FactoryGirl.create(:group_from_draw, draw: draw)
      expect(described_class.call(draw: draw)).to match_array([clip, group])
    end
    it 'does not return groups from other draws' do
      clip = FactoryGirl.create(:clip)
      FactoryGirl.create(:clip)
      result = described_class.call(draw: clip.draw)
      expect(result).to eq([clip])
    end
    it 'raises an error if no draw is provided' do
      expect { described_class.call } .to raise_error(ArgumentError)
    end
  end
end
