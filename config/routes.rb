Spree::Core::Engine.routes.draw do
  namespace :admin do
    resources :deals
  end
  resources :deals
end
