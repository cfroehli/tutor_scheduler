class TicketsController < ApplicationController
  ## Can be a db catalog, only 3 static products, let's just
  ## hardcode this for now...
  @@Products = [ { id: '0', price: 2000, hours: 1, name: 'Basic Ticket' },
                 { id: '1', price: 5000, hours: 3, name: 'Discount 3H' },
                 { id: '2', price: 7500, hours: 5, name: 'Discount 5H' } ]

  TAX_PERCENT = 0.1

  def new
    @products = @@Products
  end

  def checkout
    product_id = params[:product_id]
    product = @@Products.find {|p| p[:id] == product_id}
    # TODO raise if product = nil
    session = Stripe::Checkout::Session.create(
      customer_email: current_user.email,
      client_reference_id: current_user.id,
      payment_method_types: ['card'],
      line_items: [{
        name: 'Course Ticket',
        description: "Can be used to reserve #{product[:hours]}x1H course(s)",
        ##images: ['https://example.com/t-shirt.png'],
        amount: (product[:price] * (1 + TAX_PERCENT)).round,
        currency: 'jpy',
        quantity: 1,
      }],
      metadata: { tickets: product[:hours] },
      success_url: "#{order_success_tickets_url}?session_id={CHECKOUT_SESSION_ID}",
      cancel_url: order_cancel_tickets_url,
    )
    render json: { session_id: session.id }
  end

  def order_cancel
    flash[:success] = "Your order has been cancelled."
    redirect_to courses_path
  end

  def order_success
    flash[:success] = "Your order has been processed."
    redirect_to courses_path
  end

  def dashboard
    account = Stripe::Account.retrieve(current_user.stripe_user_id)
    login_links = account.login_links.create
    redirect_to login_links.url
  end
end
