
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

  resources :reservations, only: [:index, :show] do
    member do
      get 'cancel'
      get 'join'
      get 'leave'
      get 'pay_all_now'
      post 'receive_nonce_and_pay'
      get 'pay_with_split'
      post 'receive_nonce_and_create_unsent_bill'
      get 'pay_all_split_fees'
    end
    resources :ratings, only: [:new, :create]
    resources :comments, except: [:index, :show, :new]
  end

  devise_scope :user do
    get 'phone_verification/:id', to: "registrations#phone_verification", as: "phone_verification"
    post 'phone_verification_confirmation/:id', to: "registrations#phone_verification_confirmation", as: "phone_verification_confirmation"
  end

end
