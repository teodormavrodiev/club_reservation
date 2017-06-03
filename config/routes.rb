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
    end
    get 'join', to: "partygoers#create"
    get 'leave', to: "partygoers#destroy"
    get 'rate', to: "ratings#create"
    resources :comments, except: [:index, :show, :new]
  end

end
