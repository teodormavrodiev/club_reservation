Rails.application.routes.draw do

  devise_for :users

  root to: 'pages#home'

  resources :clubs, only: [:index, :show] do
    member do
      get 'reserve', to: "reservations#create"
    end
  end

  resources :reservations, only: [:index, :show] do
    member do
      get 'invite-friends'
      get 'show-comments'
      get 'cancel'
      get 'join'
      get 'leave'
    end
    get 'rate', to: "ratings#create"
  end

  resources :comments, except: [:index, :show, :new]

end
