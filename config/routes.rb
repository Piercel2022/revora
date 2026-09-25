Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      post "auth/register", to: "auth#register"
      post "auth/login", to: "auth#login"
      get "auth/me", to: "auth#me"
      get "dashboard", to: "dashboard#show"
      get "profile", to: "profile#show"
      patch "profile", to: "profile#update"
      patch "profile/avatar", to: "profile#update_avatar"
      delete "profile/avatar", to: "profile#destroy_avatar"
      get "organizations/:id", to: "organizations#show"
      resources :stores
      resources :customers
      resources :products
      resources :orders do
         resources :order_items
      end
      resources :segments
      resources :opportunities
      resources :integrations
    end
  end
end
