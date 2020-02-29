class StripeController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:on_event]
  skip_before_action :authenticate_user!, only: [:on_event]

  def connect
    response = HTTParty.post(
      "https://connect.stripe.com/oauth/token",
      query: {
        client_secret: Stripe.api_key,
        code: params[:code],
        grant_type: "authorization_code" })

    if response.parsed_response.key?("error")
      flash[:error] = response.parsed_response["error_description"]
    else
      stripe_user_id = response.parsed_response["stripe_user_id"]
      current_user.update_attribute(:stripe_user_id, stripe_user_id)
      flash[:success] = 'User successfully connected with Stripe!'
    end
    redirect_to new_ticket_path
  end

  def on_event
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']

    event = nil
    begin
      event = Stripe::Webhook.construct_event(request.body.read, sig_header, ENV['STRIPE_ENDPOINT_SECRET'])
    rescue JSON::ParserError
      return head :bad_request
    rescue Stripe::SignatureVerificationError
      return head :bad_request
    end

    http_status = :bad_request
    case event.type
      when 'checkout.session.completed'
        checkout_session = event.data.object
        http_status = handle_checkout_session_completed(checkout_session)
    end

    head http_status
  end

  def self.setup_products
    product = Stripe::Product.create({
      name: 'Course ticket',
      type: 'good',
      shippable: false,
      description: "Can be used to reserve 1H course",
      attributes: [ 'name', 'lot_size' ]
    })
    [ [ '1 Ticket'        , 1, 2000 ],
      [ '3 Tickets Bundle', 3, 5000 ],
      [ '5 Tickets Bundle', 5, 7500 ] ].each do |name, hours, price|
      Stripe::SKU.create({
        product: product.id,
        price: price,
        currency: 'jpy',
        inventory: { type: 'infinite' },
        attributes: { name: name, lot_size: hours }
      })
    end
  end

  private
  def handle_checkout_session_completed(checkout_session)
    user = User.find(checkout_session.client_reference_id.to_i)
    return :not_found if user.nil?

    checkout_session.display_items.each do |item|
      next unless item.type == 'sku'
      user.tickets += item.sku.attributes.lot_size.to_i
      user.save
    end
    :accepted
  end
end
