
Rails.application.routes.draw do

  mount Attachinary::Engine => "/attachinary"

  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks', registrations: 'registrations' }

  root to: 'pages#home'

  resources :clubs, only: [:index, :show] do
    member do
      get 'reserve', to: "reservations#create"
      get 'show_map', to: "clubs#show_map"
    end
  end

  resources :reservations, only: [:index] do
    member do
      get 'invited_friends'
      get 'cancel'
      get 'join'
      get 'leave'
    end
    resources :ratings, only: [:new, :create]
    resources :comments, except: [:index, :show, :new]
  end

end
