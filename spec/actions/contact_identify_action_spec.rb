require 'rails_helper'

describe ::ContactIdentifyAction do
  subject(:contact_identify) { described_class.new(contact: contact, params: params).perform }

  let!(:account) { create(:account) }
  let!(:contact) { create(:contact, account: account) }
  let(:params) { { name: 'test', identifier: 'test_id' } }

  describe '#perform' do
    it 'updates the contact' do
      expect(ContactAvatarJob).not_to receive(:perform_later).with(contact, params[:avatar_url])
      contact_identify
      expect(contact.reload.name).to eq 'test'
      expect(contact.reload.identifier).to eq 'test_id'
    end

    it 'enques avatar job when avatar url parameter is passed' do
      params = { name: 'test', avatar_url: 'https://via.placeholder.com/250x250.png' }
      expect(ContactAvatarJob).to receive(:perform_later).with(contact, params[:avatar_url]).once
      described_class.new(contact: contact, params: params).perform
    end

    context 'when contact with same identifier exists' do
      it 'merges the current contact to identified contact' do
        existing_identified_contact = create(:contact, account: account, identifier: 'test_id')
        result = contact_identify
        expect(result.id).to eq existing_identified_contact.id
        expect(result.name).to eq params[:name]
        expect { contact.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when contact with same email exists' do
      it 'merges the current contact to email contact' do
        existing_email_contact = create(:contact, account: account, email: 'test@test.com')
        params = { email: 'test@test.com' }
        result = described_class.new(contact: contact, params: params).perform
        expect(result.id).to eq existing_email_contact.id
        expect(result.name).to eq existing_email_contact.name
        expect { contact.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
