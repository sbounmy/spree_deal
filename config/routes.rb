Spree::Core::Engine.routes.draw do
  namespace :admin do
    resources :deals do
      resources :orders, :controller => "deals/orders"
      member do
        put :confirm
      end
    end
  end
  resources :deals
end
