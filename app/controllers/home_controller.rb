class HomeController < ApplicationController
  skip_before_action :authenticate_user!
  def show_homepage
    render({ :template => "home_templates/index.html.erb" })
  end

  def show_about
    render({ :template => "home_templates/about.html.erb" })
  end

  def show_support
    render({ :template => "home_templates/support.html.erb" })
  end

end