# frozen_string_literal: true

json.pub_key Rails.configuration.stripe[:publishable_key]
json.create_session_url stripe_index_path
json.cancel_subscription_url cancel_subscription_stripe_index_path
