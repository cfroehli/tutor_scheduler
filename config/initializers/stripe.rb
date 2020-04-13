# frozen_string_literal: true

Rails.configuration.stripe = {
  publishable_key: ENV['STRIPE_PUB_KEY'],
  secret_key: ENV['STRIPE_SECRET_KEY'],
  connect_id: ENV['STRIPE_CLIENT_ID']
}

Stripe.api_key = Rails.configuration.stripe[:secret_key]
