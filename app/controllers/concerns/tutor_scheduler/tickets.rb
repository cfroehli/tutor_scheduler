module TutorScheduler
  module Tickets
    STRIPE_PRODUCTS = [
      ['1 Ticket',         1, 2000],
      ['3 Tickets Bundle', 3, 5000],
      ['5 Tickets Bundle', 5, 7500],
    ].freeze

    def self.setup
      product = ::Stripe::Product.create(
        {
          name: 'Course ticket',
          type: 'good',
          shippable: false,
          description: 'Can be used to reserve 1H course',
          attributes: %w[name lot_size],
        }
      )
      STRIPE_PRODUCTS.each do |name, hours, price|
        ::Stripe::SKU.create(
          {
            product: product.id,
            price: price,
            currency: 'jpy',
            inventory: { type: 'infinite' },
            attributes: { name: name, lot_size: hours },
          }
        )
      end
    end

    def self.available
      ::Stripe::SKU
        .list
        .map do |sku|
          {
            id: sku.id,
            type: :product,
            name: sku.attributes.name,
            price: "#{sku.price}￥ (+税)",
            description: "Allow to reserve #{sku.attributes.lot_size} x 1H course.",
          }
        end
    end

    def self.create(item_id)
      stripe_sku = ::Stripe::SKU.retrieve(item_id)
      {
        mode: 'payment',
        line_items: [{
          name: stripe_sku.attributes[:name],
          amount: stripe_sku[:price],
          description: "Can be used to reserve #{stripe_sku.attributes[:lot_size]}x1H course",
          currency: 'jpy',
          quantity: 1,
        }],
        metadata: { lot_size: stripe_sku.attributes[:lot_size] },
      }
    end
  end
end
