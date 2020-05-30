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

  #club routes
  get("/new_club", { :controller => "club", :action => "club_create_form" })
  post("/create_new_club", { :controller => "club", :action => "create_club" })
  get("/my_clubs", { :controller => "club", :action => "show_clubs" })
  get("/clubs/:club_id", { :controller => "club", :action => "view_club" })

  #season routes
  get("/new_season", { :controller => "season", :action => "season_create_form" })
  post("/create_new_season", { :controller => "season", :action => "create_season" })
  get("/my_seasons", { :controller => "season", :action => "show_seasons" })
  get("/seasons/:club_id/:season_id", { :controller => "season", :action => "view_season" })
end
