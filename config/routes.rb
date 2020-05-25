Rails.application.routes.draw do

  devise_for :users
  root 'home#show_homepage'
  get("/", { :controller => "home", :action => "show_homepage" })

end
