Rails.application.routes.draw do

  devise_for :users

  resources :user do
    collection do
      get :autocomplete
    end
  end

  get("/users/autocomplete", { :controller => "user", :action => "search_users" })

  #Homepage routes
  get("/", { :controller => "home", :action => "show_homepage" })
  get("/about", { :controller => "home", :action => "show_about" })
  get("/support", { :controller => "home", :action => "show_support" })
  get("/global_markets", { :controller => "home", :action => "show_global_markets" })
  get("/getting_started", { :controller => "home", :action => "show_getting_started" })
  post("/getting_started_action", { :controller => "home", :action => "create_starter_market" })
  get("/faq", { :controller => "home", :action => "show_faq" })
  get("/test_page", { :controller => "test", :action => "test_mailgun" })
  get("/test_message", { :controller => "test", :action => "send_message" })


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
  get("/markets/manage/close/:club_id/:season_id/:market_id", { :controller => "market", :action => "close_market_page" })
  patch("/update_market_details/:club_id/:season_id/:market_id", { :controller => "market", :action => "update_market_details"})
  post("/close_market/:club_id/:season_id/:market_id", { :controller => "market", :action => "close_market_action" })
  
  #contract routes
  post("/add_market_contract/:club_id/:season_id/:market_id", { :controller => "contract", :action => "add_contract" })
  get("/contracts/:club_id/:season_id/:market_id/:contract_id", { :controller => "contract", :action => "view_contract" })
  get("/contracts/manage/:club_id/:season_id/:market_id/:contract_id", { :controller => "contract", :action => "manage_contract" })
  patch("/update_contract_details/:club_id/:season_id/:market_id/:contract_id", { :controller => "contract", :action => "update_contract_details"})

    #Trade contracts
    post("/buy_yes_contract/:contract_id", { :controller => "contract", :action => "buy_yes_contracts"})
    post("/sell_yes_contract/:contract_id", { :controller => "contract", :action => "sell_yes_contracts"})
    post("/buy_no_contract/:contract_id", { :controller => "contract", :action => "buy_no_contracts"})
    post("/sell_no_contract/:contract_id", { :controller => "contract", :action => "sell_no_contracts"})
    
    #add in once allowing for buying/selling of no for each contract
    #post("/buy_no_contract/:contract_id", { :controller => "contract", :action => "buy_no_contracts"})
    #post("/sell_no_contract/:contract_id", { :controller => "contract", :action => "sell_no_contracts"})

  #asset routes
  patch("/update_season_funds/:club_id/:season_id", { :controller => "asset", :action => "update_season_funds"})
  patch("/adjust_user_funds/:club_id/:season_id/:user_id", { :controller => "asset", :action => "adjust_user_season_funds"})


  # Membership routes
    #club memberships
  post("/add_club_memberships/:club_id", { :controller => "membership", :action => "add_club_member"})
  post("/manage_club_memberships/:club_id/:user_id", { :controller => "membership", :action => "manage_club_members"})
  post("/leave_club/:club_id", { :controller => "membership", :action => "leave_club"})

    #season memberships
  post("/add_season_memberships/:club_id/:season_id", { :controller => "membership", :action => "add_season_member"})
  post("/manage_season_memberships/:club_id/:season_id/:user_id", { :controller => "membership", :action => "manage_season_members"})
  post("/leave_season/:club_id/:season_id", { :controller => "membership", :action => "leave_season"})

    #market memberships (adds to club and season simultaneously)
  post("/add_market_memberships/:club_id/:season_id/:market_id", { :controller => "membership", :action => "add_market_member"})

  #comments
  post("/comments/club/create/:club_id/:user_id/(:parent_id)", { :controller => "comment", :action => "create_club_comment" })
  post("/comments/season/create/:season_id/:user_id/(:parent_id)", { :controller => "comment", :action => "create_season_comment" })
  post("/comments/market/create/:market_id/:user_id/(:parent_id)", { :controller => "comment", :action => "create_market_comment" })

  # get("/comments", { :controller => "comment", :action => "index" })
  # get("/comments/new/(:parent_id)", { :controller => "comment", :action => "new" })
  # post("/comments/create/:user_id", { :controller => "comment", :action => "create" })

  
end
