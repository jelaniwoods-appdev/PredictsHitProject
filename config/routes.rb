Rails.application.routes.draw do

  devise_for :users
  root 'home#show_homepage'
  get("/", { :controller => "home", :action => "show_homepage" })
  get("/about", { :controller => "home", :action => "show_about"})
  get("/support", { :controller => "home", :action => "show_support"})

end
