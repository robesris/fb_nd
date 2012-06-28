FbNd::Application.routes.draw do
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  resources :games

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)
  match 'create_game' => 'games#create', :as => :create_game
  match 'game/:game_code/:player_secret' => 'games#join', :as => :join_game
  match 'game/:game_code/:player_secret/draft/:piece_name/:space' => 'games#draft', :as => :draft
  match 'game/:game_code/:player_secret/move/:piece_unique_name/:space' => 'games#move', :as => :move
  match 'game/:game_code/:player_secret/summon/:piece_unique_name/:space' => 'games#summon', :as => :summon
  match 'game/:game_code/:player_secret/pass_turn' => 'games#pass_turn', :as => :pass_turn
  match 'game/:game_code/:player_secret/flip/:piece_unique_name' => 'games#flip', :as => :flip
  match 'game/:game_code/:player_secret/events' => 'games#check_for_events', :as => :check_for_events
  match 'game/:game_code/:player_secret/init' => 'games#init', :as => :init
  match 'game/:game_code/:player_secret/ready' => 'games#ready', :as => :ready

    # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products
  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => 'games#new'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
