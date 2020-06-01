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
          attributes = sku.attributes
          {
            id: sku.id,
            type: :product,
            name: attributes.name,
            price: "#{sku.price}￥ (+税)",
            description: "Allow to reserve #{attributes.lot_size} x 1H course.",
          }
        end
    end

    def self.create(item_id)
      sku = ::Stripe::SKU.retrieve(item_id)
      attributes = sku.attributes
      {
        mode: 'payment',
        line_items: [{
          name: attributes[:name],
          amount: sku[:price],
          description: "Can be used to reserve #{attributes[:lot_size]}x1H course",
          currency: 'jpy',
          quantity: 1,
        }],
        metadata: { lot_size: attributes[:lot_size] },
      }
    end
  end
end
