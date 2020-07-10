# frozen_string_literal: true

namespace :stripe do
  desc 'Setup stripe products'
  task setup_products: :environment do
    StripeController.setup_products
  end
end
