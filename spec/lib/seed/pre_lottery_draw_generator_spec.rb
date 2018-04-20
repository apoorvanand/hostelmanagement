# frozen_string_literal: true

require 'rails_helper'

describe PreLotteryDrawGenerator do
  describe '.generate' do
    it 'makes a new draw' do
      expect { described_class.generate }.to \
        change { Draw.count }.by(1)
    end

    it 'makes the draw be in pre-lottery' do
      expect(described_class.generate).to be_pre_lottery
    end
  end
end
