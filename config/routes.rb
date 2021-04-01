Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'welcome#index'

  resources :movies, only: [:index, :show]
  get '/registration', to: 'users#new'
  post '/registration', to: 'users#create'
  resources :users, only: [:create]
  post '/login', to: 'users#login'
  delete '/logout', to: 'users#destroy'
  get '/dashboard', to: 'users#dashboard'
  get '/discover', to: 'discover#index'

  resources :parties, only: [:new, :create]
  resources :cast, only: [:show]


  resources :friends, only: [:create]
end
