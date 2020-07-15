class TestController < ApplicationController

  def send_message
  
    mg_api_key = ENV.fetch("MAILGUN_API_KEY")
    mg_sending_domain = ENV.fetch("MAILGUN_DOMAIN")

    # Create an instance of the Mailgun Client and authenticate with your API key
    mg_client = Mailgun::Client.new(mg_api_key)

    # Craft your email as a Hash with these four keys
    email_parameters =  { 
      :from => "Admin@predictshit.com",
      :to => "thegegors@gmail.com",  
      :subject => "Test Subject Prod",
      :text => "Test Text Prod"
    }

    # Send your email!
    mg_client.send_message(mg_sending_domain, email_parameters)

    redirect_to("/global_markets")
  end
  
end

