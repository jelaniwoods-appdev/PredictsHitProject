class HomeController < ApplicationController
  def show_homepage
    render({ :template => "home_templates/index.html.erb" })
  end
end
