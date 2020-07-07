class HomeController < ApplicationController
  skip_before_action :authenticate_user!, except: [:show_getting_started]
  def show_homepage
    render({ :template => "home_templates/index.html.erb" })
  end

  def show_about
    render({ :template => "home_templates/about.html.erb" })
  end

  def show_support
    render({ :template => "home_templates/support.html.erb" })
  end

  def show_global_markets
    render({ :template => "home_templates/global_markets.html.erb" })
  end

  def show_getting_started
    render({ :template => "home_templates/getting_started.html.erb" })
  end

end