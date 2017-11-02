# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ClipMembershipUpdater do
  let(:clip) { instance_spy('Clip', draw: instance_spy('Draw'), name: 'Test') }
  let(:group) { instance_spy('Group', name: 'Name') }
  let(:params) { instance_spy('ActionController::Parameters', to_h: {}) }

  it 'successfully updates a clip membership' do
    membership = instance_spy('ClipMembership', clip: clip, confirmed: false,
                                                group: group)
    described_class.update(clip_membership: membership, params: params)
    expect(membership).to have_received(:update!)
  end

  it 'returns an array with the draw and the clip from the membership' do
    membership = instance_spy('ClipMembership', clip: clip, confirmed: false,
                                                group: group, update!: true)
    updater = described_class.new(clip_membership: membership, params: params)
    expect(updater.update[:redirect_object]).to eq(clip)
  end

  it 'returns the correct success message' do
    membership = instance_spy('ClipMembership', clip: clip, confirmed: false,
                                                group: group, update!: true)
    updater = described_class.new(clip_membership: membership, params: params)
    expect(updater.update[:msg][:success]).to \
      eq("#{group.name} joined #{clip.name}.")
  end
end
