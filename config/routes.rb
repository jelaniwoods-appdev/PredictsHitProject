Rails.application.routes.draw do

  devise_for :users

  resources :user do
    collection do
      get :autocomplete
    end
  end

  get("/users/autocomplete", { :controller => "user", :action => "search_users" })

  #Homepage routes
  root to: 'home#show_homepage'
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
  resources :clubs, except: [:destroy, :edit]


  #season routes
  post("/close_season/:club_id/:season_id", { :controller => "seasons", :action => "close_season"})
  resources :seasons, except: [:destroy, :edit]

  #market routes
  post("/close_market/:club_id/:season_id/:market_id", { :controller => "markets", :action => "close_market" })
  post("/pause_market/:club_id/:season_id/:market_id", { :controller => "markets", :action => "pause_market" })
  post("/unpause_market/:club_id/:season_id/:market_id", { :controller => "markets", :action => "unpause_market" })
  resources :markets, except: [:destroy, :edit]
  
  #contract routes
  post("/add_market_contract/:club_id/:season_id/:market_id", { :controller => "contract", :action => "add_contract" })
  get("/contracts/:club_id/:season_id/:market_id/:contract_id", { :controller => "contract", :action => "view_contract" })
  get("/contracts/manage/:club_id/:season_id/:market_id/:contract_id", { :controller => "contract", :action => "manage_contract" })
  patch("/update_contract_details/:club_id/:season_id/:market_id/:contract_id", { :controller => "contract", :action => "update_contract_details"})

  get("/contracts/:contract_id", { controller: "contract", action: "show" })

    #Trade contracts
    post("/buy_yes_contract/:contract_id", { :controller => "contract", :action => "buy_yes_contracts"})
    post("/sell_yes_contract/:contract_id", { :controller => "contract", :action => "sell_yes_contracts"})
    post("/buy_no_contract/:contract_id", { :controller => "contract", :action => "buy_no_contracts"})
    post("/sell_no_contract/:contract_id", { :controller => "contract", :action => "sell_no_contracts"})

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

  #comments / messages
  post("/messages/club/create/:club_id/:user_id", { :controller => "chat", :action => "create_club_message" })
  post("/messages/season/create/:club_id/:season_id/:user_id", { :controller => "chat", :action => "create_season_message" })
  post("/messages/market/create/:club_id/:season_id/:market_id/:user_id", { :controller => "chat", :action => "create_market_message" })

end
