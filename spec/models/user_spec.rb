# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'User model:', type: :model do
  let(:user) { create(:user) }

  context 'when created' do
    it 'must have a free ticket available' do
      expect(user.remaining_tickets).to eq(1)
    end

    it 'must have the user role' do
      expect(user.has_role?(:user)).to be true
    end
  end

  context 'when managing tickets' do
    it 'can add tickets without expiration date' do
      expect { user.add_tickets(1) }.to change(user, :remaining_tickets).by(1)
      #expect(user.tickets.order(created_at: :desc).pluck(:expiration).first).to be_nil
    end

    it 'can add tickets with expiration date' do
      expiration = (DateTime.now + 1.day).change(usec: 0)
      expect { user.add_tickets(1, expiration) }.to change(user, :remaining_tickets).by(1)
      expect(user.tickets_validity).to include([expiration.utc, 1])
    end

    it 'can use a ticket' do
      expect { user.use_ticket }.to change(user, :remaining_tickets).by(-1)
    end

    it 'uses ticket with closest expiration date in priority' do
      expiration = (DateTime.now + 1.hour).change(usec: 0)
      user.add_tickets(1, expiration)
      user.add_tickets(1)
      expect(user.tickets_validity).to include([expiration.utc, 1])
      expect { user.use_ticket }.to change(user, :remaining_tickets).by(-1)
      expect(user.tickets_validity).not_to include([expiration.utc, 1])
    end
  end
end
