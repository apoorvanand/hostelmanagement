# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ClipPolicy do
  subject { described_class }

  let(:clip) { FactoryGirl.build_stubbed(:clip) }

  context 'student' do
    let(:user) { FactoryGirl.build_stubbed(:user, role: 'student') }

    permissions :assign_lottery? do
      it { is_expected.not_to permit(user, clip) }
    end
  end
  context 'housing rep' do
    let(:user) { FactoryGirl.build_stubbed(:user, role: 'rep') }

    permissions :assign_lottery? do
      it { is_expected.to permit(user, clip) }
    end
  end
  context 'admin' do
    let(:user) { FactoryGirl.build_stubbed(:user, role: 'admin') }

    permissions :assign_lottery? do
      it { is_expected.to permit(user, clip) }
    end
  end
end
