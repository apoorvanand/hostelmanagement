# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Clip, type: :model do
  describe 'basic validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_numericality_of(:lottery_number) }
    it { is_expected.to have_many(:groups) }
    it { is_expected.to belong_to(:draw) }
  end

  describe 'validations' do
    context 'on lottery number' do
      it "ensure all groups have the clip's lottery number" do

      end
    end
  end

  describe 'method wrappers' do
    context 'allow for duck typing on all needed group methods' do
      it 'works for #[insert_method_here]' do
        #emails?
        #locked?
        #
      end
    end
  end
end
