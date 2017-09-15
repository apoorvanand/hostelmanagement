# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DrawStudentsUpdatePolicy do
  subject { described_class }

  let(:draw_students_update) { instance_spy('draw_students_update') }

  context 'student' do
    let(:user) { FactoryGirl.build_stubbed(:user, role: 'student') }

    permissions :index?, :edit?, :update?, :bulk_assign? do
      it { is_expected.not_to permit(user, draw_students_update) }
    end
  end

  context 'housing rep' do
    let(:user) { FactoryGirl.build_stubbed(:user, role: 'rep') }

    permissions :index?, :edit?, :update?, :bulk_assign? do
      it { is_expected.to permit(user, draw_students_update) }
    end
  end

  context 'admin' do
    let(:user) { FactoryGirl.build_stubbed(:user, role: 'admin') }

    permissions :index?, :edit?, :update?, :bulk_assign? do
      it { is_expected.to permit(user, draw_students_update) }
    end
  end
end
