# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserBuilder do
  describe '#build' do
    context 'success' do
      it 'returns instance of User class' do
        result = described_class.build(id_attr: 'foo',
                                       college: instance_spy('college'))
        expect(result[:user]).to be_instance_of(User)
      end
      it 'returns unpersisted record' do
        result = described_class.build(id_attr: 'foo',
                                       college: instance_spy('college'))
        expect(result[:user].persisted?).to be_falsey
      end
      it 'looks up profile data' do
        querier = mock_profile_querier(first_name: 'John')
        ub = described_class.new(id_attr: 'foo', querier: querier,
                                 college: instance_spy('college'))
        result = ub.build
        expect(result[:user][:first_name]).to eq('John')
      end
      it 'assigns the user to the relevant college if passed' do
        college = instance_spy('college', id: 1)
        result = described_class.new(id_attr: 'foo', college: college).build
        expect(result[:user][:college_id]).to eq(college.id)
      end
      it 'returns a success flash' do
        result = described_class.build(id_attr: 'foo',
                                       college: instance_spy('college'))
        expect(result[:msg]).to have_key(:success)
      end
      it 'returns action: new' do
        result = described_class.build(id_attr: 'foo',
                                       college: instance_spy('college'))
        expect(result[:action]).to eq('new')
      end
      context 'with CAS' do # rubocop:disable RSpec/NestedGroups
        before { allow(User).to receive(:cas_auth?).and_return(true) }
        it 'sets the username to the username' do
          result = described_class.build(id_attr: 'foo',
                                         college: instance_spy('college'))
          expect(result[:user].username).to eq('foo')
        end
        it 'does not set the email' do
          result = described_class.build(id_attr: 'foo',
                                         college: instance_spy('college'))
          expect(result[:user].email).to be_empty
        end
      end
      context 'without CAS' do # rubocop:disable RSpec/NestedGroups
        it 'sets the email to the username' do
          result = described_class.build(id_attr: 'foo',
                                         college: instance_spy('college'))
          expect(result[:user].email).to eq('foo')
        end
      end
    end

    context 'failure' do
      context 'without CAS, taken email' do # rubocop:disable RSpec/NestedGroups
        it 'returns new instance of User' do
          user_spy = instance_spy('ActiveRecord::Relation', count: 1)
          allow(User).to receive(:where).with(email: 'foo').and_return(user_spy)
          result = described_class.build(id_attr: 'foo',
                                         college: instance_spy('college'))
          expect(result[:user].attributes).to eq(User.new.attributes)
        end
        it 'returns an error flash' do
          user_spy = instance_spy('ActiveRecord::Relation', count: 1)
          allow(User).to receive(:where).with(email: 'foo').and_return(user_spy)
          result = described_class.build(id_attr: 'foo',
                                         college: instance_spy('college'))
          expect(result[:msg]).to have_key(:error)
        end
        it 'returns action: build' do
          user_spy = instance_spy('ActiveRecord::Relation', count: 1)
          allow(User).to receive(:where).with(email: 'foo').and_return(user_spy)
          result = described_class.build(id_attr: 'foo',
                                         college: instance_spy('college'))
          expect(result[:action]).to eq('build')
        end
      end
    end
  end

  context '#exists?' do
    context 'without CAS' do
      it 'returns true if that identifying attribute is already taken' do
        user_spy = instance_spy('ActiveRecord::Relation', count: 1)
        college = instance_spy('college')
        allow(User).to receive(:where).with(email: 'foo').and_return(user_spy)
        ub = described_class.new(id_attr: 'foo', college: college)
        expect(ub.exists?).to be_truthy
      end
      it 'returns false if that identifying attribute is not already taken' do
        user_spy = instance_spy('ActiveRecord::Relation', count: 0)
        college = instance_spy('college')
        allow(User).to receive(:where).with(email: 'foo').and_return(user_spy)
        ub = described_class.new(id_attr: 'foo', college: college)
        expect(ub.exists?).to be_falsey
      end
    end
  end

  def mock_user_builder(params_hash)
    instance_spy('UserBuilder').tap do |user_builder|
      allow(UserBuilder).to receive(:new).with(params_hash)
                                         .and_return(user_builder)
    end
  end

  def mock_profile_querier(**profile_data)
    class_spy('IdrProfileQuerier').tap do |pq|
      allow(pq).to receive(:query).and_return(profile_data)
    end
  end
end
