# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Manual user creation', type: :request do
  let(:college) { create(:college) }
  let(:admin) { create(:admin, college: college) }

  before do
    host! "#{college.subdomain}.lvh.me"
    post user_session_path,
         params: { user: { email: admin.email, password: 'passw0rd' } }
  end

  it 'automatically sets the college' do
    attrs = %i(first_name last_name role email gender username class_year)
    user_params = attributes_for(:user).slice(*attrs)
    post users_path, params: { user: user_params }
    expect(User.last.college).to eq(college)
  end

  it 'prevents non-superusers from creating superusers' do
    attrs = %i(first_name last_name role email gender username class_year)
    user_params = attributes_for(:user).slice(*attrs).merge(role: 'superuser')
    post users_path, params: { user: user_params }
    expect(User.last.role).to eq('student')
  end
end
