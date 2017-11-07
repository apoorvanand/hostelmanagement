# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Clip, type: :model do
  describe 'basic validations' do
    it { is_expected.to have_many(:groups) }
    it { is_expected.to belong_to(:draw) }
  end

  describe 'validations' do
    context 'on lottery number' do
      it 'check if all groups have the same lottery number' do
        clip = FactoryGirl.create(:clip)
        clip.groups.first.update!(lottery_number: 1)
        clip.groups.last.update!(lottery_number: 2)
        expect(clip.valid?).to be_falsey
      end

      xit 'raise an error if groups have different lottery numbers'
    end
  end

  describe '#clip_cleanup' do
    context 'is called when groups are deleted' do
      xit 'and deletes the clip when it has no more groups' do

      end

      xit 'does nothing if there are more groups left' do

      end
    end
  end

  describe 'method wrappers' do
    context 'allow for duck typing on all needed group methods' do
      xit 'works for #[insert_method_here]' do
        #emails?
        #locked?
        #
      end
    end
  end
end
