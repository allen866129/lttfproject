Lttfproject::Application.routes.draw do

  


  resources :shopcarts do
    collection do
      get :shopcartstoxls
    end
  end 
  resources :gsheet4games


  resources :blacklists


  resources :blacklists do 
    collection do
       post :toggleblacklist
       post :blacklistsearch
    end
  end    


  resources :advitems


 #match '/home' => 'home#index'
 #match '/home' => 'home#index', :via => [:get], :as => 'home_index'
 resources :holdgames do
      resources :gamegroups, :controller => 'holdgame_gamegroups' do
        collection do
          post :registration
          post :cancel_team_registration
          post :cancel_singleplayer_registration
          post :cancel_double_registration
          post :cancel_singleplayer_registration_inteam
          get :playerinput
          get :singleplayerinput
          get :doubleplayersinput
          get :teamplayersinput
          get :teamplayersadd
          get :singlegroupregistration
          put :update
          get :groupdumptoxls
          get :preparesendmail
          post :sendemail
          get :publishtoFB
         end  
        
      end
    collection do
      get :copy_players_list
      get :coholders
      post :cancel
      get :publish_all
    end  
  end


  resources :uploadgames do
    collection do
      get  :upload
      get  :displayuploadfile
      get  :uploadfile_fromholdgame
      post :savetoupload
      post :publishuploadgame
      post :publish_trycalculation
      post :calculategamepage
      post :trycalculation
      post :caculatescore
      get  :gamescorechecking
      get  :show_player_games
      get  :cal_show_player_games
      get  :publish_show_player_games
      get  :displayupload_show_player_games
    end
    member do
      post :calculategamepage
      get :trycalculation
      post :caculatescore
    end  
  end  
  
  resources :games do
    collection do 
      get  :show_player_games
      get   :lttfratinginfo
    end  
  end


devise_for :users, :controllers => {:registrations => 'users/registrations', :omniauth_callbacks => 'users/omniauth_callbacks' }
#devise_for :users, :controllers => { :registrations => 'users/registrations'}  

  devise_scope :user do
      resources :users 
  end
  root :to => "home#index"
  resources :playerprofiles do
     collection do
       post :import 
       get :search
       get :googleplayerlist   
       get :callback   
       get :lttfindex  
       #post :toggleblacklist
     end   
  end
  
  resources :ttcourts 
  resources :gameholders do
     collection do
       get :approveprocess 
       post :approve
       get :demos
     end 
  end 
  resources :gamesmaps do
     collection do
      put :update
      get :lttfgamesindex
     end
  end
  resources :gamecoholders do
     collection do
       get :coholderinput
     end 
  end   
  get "fbconnections/removefbconnect" => "fbconnections#removefbconnect"
  get "fbconnections/resetfbconnect" => "fbconnections#resetfbconnect"
  
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
 
  #   resources :produ  cts
 
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
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
 ActiveAdmin.routes(self)
end
