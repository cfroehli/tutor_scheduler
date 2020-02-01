Rails.application.routes.draw do
  devise_for :users, path: 'auth', path_names: {sign_in: 'login', sign_out: 'logout', sign_up: 'register'}
  resources :users, only: [:index] do
    post :impersonate, on: :member
    post :stop_impersonating, on: :collection
  end
  resources :courses,
    path: '/courses(/lang/:language)(/teacher/:teacher)(/:year(/:month(/:day(/:hour))))',
    only: [:index, :create],
    constraints: {
      language: /\w+/,
      teacher: /\w+/,
      year: /\d+/,
      month: /\d+/,
      day: /\d+/,
      hour: /\d+/ }
  resources :courses, only: [:create] do
    post 'sign_up', on: :member
    get 'list', on: :collection
  end
  resources :tickets, only: [:new, :create] do
    collection do
      get 'checkout', constraints: {format: 'json'}
      get 'order_success'
      get 'order_cancel'
      get 'dashboard'
    end
  end
  resources :teached_languages, only: [] do
    member do
      get 'activate'
      get 'deactivate'
    end
  end
  resources :teachers, except: [:destroy] do
    post 'add_language', on: :collection
  end
  resources :stripe, only: [] do
    collection do
      get 'connect'
      post 'on_event'
    end
  end
  root to: "users#dashboard"
end
