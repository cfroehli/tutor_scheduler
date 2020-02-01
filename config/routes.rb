Rails.application.routes.draw do
  devise_for :users, path: 'auth', path_names: { sign_in: 'login', sign_out: 'logout', sign_up: 'register' }
  scope :courses do
    post 'sign_up/:id', to: 'courses#sign_up', as: 'sign_up', constraints: { id: /\d+/ }
    get 'list', to: 'courses#list', as: 'list'
  end
  resources :courses, path: '/courses(/:year(/:month(/:day(/:hour))))', only: [ :index, :new, :create ], constraints: { year: /\d+/, month: /\d+/, day: /\d+/, hour: /\d+/ }
  resources :tickets, only: [:new, :create]
  resources :teachers
  root to: "users#dashboard"
end
