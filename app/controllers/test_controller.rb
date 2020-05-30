class TestController < ApplicationController
  
  def test_mailgun
    # Retrieve mailgun credentials from secure storage
    mg_api_key = ENV.fetch("MAILGUN_API_KEY")
    mg_sending_domain = ENV.fetch("MAILGUN_SENDING_DOMAIN")

    # Create an instance of the Mailgun Client and authenticate with API key
    mg_client = Mailgun::Client.new(mg_api_key)

    # Create email here as hash with 4 keys
    email_parameters =  { 
      :from => "admin@predictshit.com",
      :to => "thegegors@gmail.com",  # change to be based on who requests it
      :subject => "Test Subject!",
      :text => "Thank you for creating an account. Please click on the following link to verify your email:"
    }
    # Send the email
    # need to fix -> mg_client.send_message(mg_sending_domain, email_parameters)

    #render test form just to see if it works
    render({ :template => "test_templates/mailgun_form.html.erb" })

  end
end

