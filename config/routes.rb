Rails.application.routes.draw do

  devise_for :users

  #Homepage routes
  get("/", { :controller => "home", :action => "show_homepage" })
  get("/about", { :controller => "home", :action => "show_about" })
  get("/support", { :controller => "home", :action => "show_support" })
  get("/test_page", { :controller => "test", :action => "test_mailgun" })

  #profile routes
  get("/profile/:user_id", { :controller => "profile", :action => "show_profile" })
  get("/profile/manage/:user_id", { :controller => "profile", :action => "manage_profile_page" })
  patch("/update_profile/:user_id", { :controller => "profile", :action => "update_profile" })


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
  get("/seasons/manage/:club_id/:season_id", { :controller => "season", :action => "manage_season" })
  patch("/update_season_details/:club_id/:season_id", { :controller => "season", :action => "update_season_details"})

  #market routes
  get("/new_market", { :controller => "market", :action => "market_create_form" })
  post("/create_new_market", { :controller => "market", :action => "create_market" })
  get("/my_markets", { :controller => "market", :action => "show_markets" })
  get("/markets/:club_id/:season_id/:market_id", { :controller => "market", :action => "view_market" })
  get("/markets/manage/:club_id/:season_id/:market_id", { :controller => "market", :action => "manage_market" })
  patch("/update_market_details/:club_id/:season_id/:market_id", { :controller => "market", :action => "update_market_details"})
  
  #contract routes
  post("/add_market_contract/:club_id/:season_id/:market_id", { :controller => "contract", :action => "add_contract" })
  get("/contracts/:club_id/:season_id/:market_id/:contract_id", { :controller => "contract", :action => "view_contract" })
  get("/contracts/manage/:club_id/:season_id/:market_id/:contract_id", { :controller => "contract", :action => "manage_contract" })
  patch("/update_contract_details/:club_id/:season_id/:market_id/:contract_id", { :controller => "contract", :action => "update_contract_details"})

    #Trade contracts
    post("/buy_yes_contract/:contract_id", { :controller => "contract", :action => "buy_yes_contracts"})
    post("/buy_no_contract/:contract_id", { :controller => "contract", :action => "buy_no_contracts"})
    post("/sell_yes_contract/:contract_id", { :controller => "contract", :action => "sell_yes_contracts"})
    post("/sell_no_contract/:contract_id", { :controller => "contract", :action => "sell_no_contracts"})

  # Membership routes
    #club memberships
  post("/add_club_memberships/:club_id", { :controller => "membership", :action => "add_club_member"})

    #season memberships
  post("/add_season_memberships/:club_id/:season_id", { :controller => "membership", :action => "add_season_member"})

end
