# Load the Rails application.
require_relative 'application'

# Initialize the Rails application.
Rails.application.initialize!

ActionMailer::Base.smtp_settings = {
  :user_name => ENV.fetch("SENDGRIDUSERNAME"),
  :password => ENV.fetch("SENDGRIDPASSWORD"),
  :domain => 'predictshit.com',
  :address => 'smtp.sendgrid.net',
  :port => 465,
  :authentication => :plain,
  :enable_starttls_auto => true
}
