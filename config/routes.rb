Rails.application.routes.draw do

  devise_for :users

  #Homepage routes
  get("/", { :controller => "home", :action => "show_homepage" })
  get("/about", { :controller => "home", :action => "show_about" })
  get("/support", { :controller => "home", :action => "show_support" })
  get("/test_page", { :controller => "test", :action => "test_mailgun" })

  #account routes
  get("/profile/:user_id", { :controller => "account", :action => "show_account" })

  post("/create_new_account/:user_id", { :controller => "account", :action => "create_account" })

  post("/edit_account/:account_id", { :controller => "account", :action => "edit_account" })

  #club routes
  get("/new_club", { :controller => "club", :action => "club_create_form" })
  post("/create_new_club", { :controller => "club", :action => "create_club" })
  get("/my_clubs", { :controller => "club", :action => "show_clubs" })
  get("/clubs/:club_id", { :controller => "club", :action => "view_club" })
  get("/clubs/manage/:club_id", { :controller => "club", :action => "manage_club" })
  patch("/update_club_details/:club_id", { :controller => "club", :action => "update_club_details"})


  #season routes
  get("/new_season", { :controller => "season", :action => "season_create_form" })
  post("/create_new_season", { :controller => "season", :action => "create_season" })
  get("/my_seasons", { :controller => "season", :action => "show_seasons" })
  get("/seasons/:club_id/:season_id", { :controller => "season", :action => "view_season" })

  #market routes
  get("/new_market", { :controller => "market", :action => "market_create_form" })
  post("/create_new_market", { :controller => "market", :action => "create_market" })
  get("/my_markets", { :controller => "market", :action => "show_markets" })
  get("/markets/:club_id/:market_id/:market_id", { :controller => "market", :action => "view_market" })

  # Membership routes
    #club memberships
    post("/add_club_memberships/:club_id", { :controller => "membership", :action => "add_club_member"})

end
