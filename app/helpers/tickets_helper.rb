module TicketsHelper
  def stripe_button_link
    stripe_url = "https://connect.stripe.com/express/oauth/authorize"
    client_id = Rails.configuration.stripe[:connect_id]
    user_email = current_user.email
    "#{stripe_url}?redirect_uri=#{checkout_tickets_url}&client_id=#{client_id}&stripe_user[email]=#{user_email}"
  end
end
