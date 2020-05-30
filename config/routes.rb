Rails.application.routes.draw do

  devise_for :users

  #Homepage routes
  get("/", { :controller => "home", :action => "show_homepage" })
  get("/about", { :controller => "home", :action => "show_about" })
  get("/support", { :controller => "home", :action => "show_support" })
  get("/test_page", { :controller => "test", :action => "test_mailgun" })

  #account routes
  get("/profile", { :controller => "account", :action => "show_account" })

  post("/create_new_account/:user_id", { :controller => "account", :action => "create_account" })

  post("/edit_account/:account_id", { :controller => "account", :action => "edit_account" })
  
end
