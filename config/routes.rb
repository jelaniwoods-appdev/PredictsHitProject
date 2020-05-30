Rails.application.routes.draw do

  devise_for :users

  get("/", { :controller => "home", :action => "show_homepage" })
  get("/about", { :controller => "home", :action => "show_about" })
  get("/support", { :controller => "home", :action => "show_support" })
  get("/test_page", { :controller => "test", :action => "test_mailgun" })

end
