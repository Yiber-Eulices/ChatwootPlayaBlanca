# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ContactPolicy, type: :policy do
  subject(:contact_policy) { described_class }

  let(:account) { create(:account) }

  let(:administrator) { create(:user, :administrator, account: account) }
  let(:agent) { create(:user, account: account) }
  let(:contact) { create(:contact) }

  permissions :index?, :show?, :update? do
    context 'when administrator' do
      it { expect(contact_policy).to permit(administrator, contact) }
    end

    context 'when agent' do
      it { expect(contact_policy).not_to permit(agent, contact) }
    end
  end

  permissions :create? do
    context 'when administrator' do
      it { expect(contact_policy).to permit(administrator, contact) }
    end

    context 'when agent' do
      it { expect(contact_policy).to permit(agent, contact) }
    end
  end
end
