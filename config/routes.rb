Rails.application.routes.draw do

  devise_for :users
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root 'home#index'
  
  resources :allusers, only: [:show, :index]

  resources :posts

  resources :comments

  resources :likes

  resources :friendships

  get :pending_requests, to: 'friendships#pending'
end
