Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      post "auth/register", to: "auth#register"
      post "auth/login", to: "auth#login"
      get "auth/me", to: "auth#me"

      get "profile", to: "profile#show"

      get "organizations/:id", to: "organizations#show"
      resources :stores
      resources :customers
      resources :products
      resources :orders do
         resources :order_items
      end
      resources :segments
    end
  end
end
