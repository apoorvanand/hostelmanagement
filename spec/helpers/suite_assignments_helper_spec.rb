# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SuiteAssignmentsHelper, type: :helper do
  describe '#show_skip_btn?' do
    let(:draw) { instance_spy('draw') }

    context 'draw is not present' do
      before { allow(draw).to receive(:present?).and_return(false) }

      it 'is falsey' do
        expect(helper.show_skip_btn?(draw)).to be_falsey
      end
    end

    context 'draw is present' do
      before { allow(draw).to receive(:present?).and_return(true) }

      it 'is falsey if the draw policy does not permit group actions' do
        dp = instance_spy('draw_policy', group_actions?: false)
        without_partial_double_verification do
          allow(helper).to receive(:policy).with(draw).and_return(dp)
        end
        expect(helper.show_skip_btn?(draw)).to be_falsey
      end
      it 'is truthy if the draw policy permits group actions' do
        dp = instance_spy('draw_policy', group_actions?: true)
        without_partial_double_verification do
          allow(helper).to receive(:policy).with(draw).and_return(dp)
        end
        expect(helper.show_skip_btn?(draw)).to be_truthy
      end
    end
  end
end
