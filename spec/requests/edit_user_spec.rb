# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Edit User API', type: :request do
  describe 'PATCH /api/v1/users/:id/intent' do
    context 'as a student in a draw' do
      let(:draw) { FactoryGirl.create(:draw, status: 'pre_lottery') }
      let(:student) do
        FactoryGirl.create(:student, intent: 'undeclared',
                                     password: 'asdfjkl;',
                                     draw: draw)
      end
      let(:another_student) do
        FactoryGirl.create(:student, intent: 'undeclared',
                                     password: 'asdfjkl;', draw: draw)
      end

      before { api_login student }

      it 'returns status success' do
        patch update_intent_api_v1_user_path(student.id),
              params: { user: { intent: 'on_campus' } }
        expect(response).to have_http_status(200)
      end

      it 'returns status unauthorized when invalid permissions' do
        patch update_intent_api_v1_user_path(another_student.id),
              params: { user: { intent: 'on_campus' } }
        expect(response).to have_http_status(401)
      end

      it 'returns status internal server error when update fails' do
        update_failure_result = { redirect_object: nil, record: nil, msg: {} }
        allow(Updater).to receive(:update).and_return(update_failure_result)
        patch update_intent_api_v1_user_path(student.id),
              params: { user: { intent: 'on_campus' } }
        expect(response).to have_http_status(500)
      end
    end
  end
end
