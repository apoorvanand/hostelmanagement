# frozen_string_literal: true

require 'rails_helper'

RSpec.describe College do
  describe '.current' do
    it 'returns the current tenant' do
      college = create(:college, subdomain: 'foo')
      Apartment::Tenant.switch!('foo')
      expect(described_class.current).to eq(college)
    end

    it 'returns a null college if in the public schema' do
      Apartment::Tenant.reset
      college = instance_spy('college')
      allow(described_class).to receive(:new).and_return(college)
      expect(described_class.current).to eq(college)
    end
  end

  describe 'associations' do
    it { is_expected.to have_many(:users) }
  end

  describe 'validations' do
    subject { FactoryGirl.build(:college) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:admin_email) }
    it { is_expected.to validate_presence_of(:dean) }
    it { is_expected.to validate_presence_of(:site_url) }
    it { is_expected.to validate_uniqueness_of(:subdomain).case_insensitive }
  end

  describe 'subdomain callback' do
    it 'automatically sets a subdomain if missing based on name' do
      college = FactoryGirl.build(:college, name: 'foo', subdomain: nil)
      college.save!
      expect(college.subdomain).to eq('foo')
    end

    it 'downcases and escapes invalid characters' do
      college = FactoryGirl.build(:college, name: 'Foo Bar?', subdomain: nil)
      college.save!
      [' ', '?', 'B'].each { |c| expect(college.subdomain).not_to include(c) }
    end

    it 'does not overwrite existing values' do
      college = FactoryGirl.build(:college, subdomain: 'hello')
      college.save!
      expect(college.subdomain).to eq('hello')
    end
  end

  describe 'apartment callback' do
    it 'creates a schema on create' do
      allow(Apartment::Tenant).to receive(:create).with('foo')
      FactoryGirl.create(:college, subdomain: 'foo')
      expect(Apartment::Tenant).to have_received(:create).with('foo')
    end
  end
end
