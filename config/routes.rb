Rails.application.routes.draw do


  resources :users, only: [:show, :index]
  devise_for :users
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root 'home#index'
  
end
