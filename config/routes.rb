Spree::Core::Engine.routes.draw do
  namespace :admin do
    resources :deals do
      resources :orders, :controller => "deals/orders"
    end
  end
  resources :deals
end
