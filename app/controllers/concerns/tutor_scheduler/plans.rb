module TutorScheduler
  module Plans
    STRIPE_PLANS = [
      ['5 Tickets',   5,  7_000],
      ['7 Tickets',   7,  9_500],
      ['10 Tickets', 10, 12_000],
    ].freeze

    def self.setup
      product = ::Stripe::Product.create(
        {
          name: 'Plan ticket',
          type: 'service',
          description: 'Can be used to reserve 1H course',
        }
      )
      STRIPE_PLANS.each do |name, hours, price|
        ::Stripe::Plan.create(
          {
            nickname: "#{name} per month",
            interval: 'month',
            currency: 'jpy',
            amount: price,
            product: product.id,
            metadata: { lot_size: hours },
          }
        )
      end
    end

    def self.available
      ::Stripe::Plan
        .list
        .map do |plan|
          {
            id: plan.id,
            type: :subscription,
            name: plan.nickname,
            price: "#{plan.amount}￥",
            description: "Allow to reserve #{plan.metadata[:lot_size]} x 1H course. Automatically renewed, unused tickets are lost at the end of the period.",
          }
        end
    end

    def self.create(item_id)
      stripe_plan = ::Stripe::Plan.retrieve(item_id)
      {
        mode: 'subscription',
        subscription_data: { items: [{ plan: stripe_plan.id, quantity: 1 }] },
        metadata: { lot_size: stripe_plan.metadata[:lot_size] },
      }
    end
  end
end
