Rails.application.routes.draw do
  devise_for :users, path: 'auth', path_names: {sign_in: 'login', sign_out: 'logout', sign_up: 'register'}
  resources :users, only: [] do
    get 'courses_history', on: :member
  end
  resources :admin, only: [:index] do
    post :impersonate, on: :member
    post :stop_impersonating, on: :collection
  end
  resources :stats, only: [:index] do
    collection do
      get 'courses_hourly', format: :json
      get 'courses_teachers', format: :json
      get 'courses_teacher_monthly', format: :json
      get 'courses_teacher_weekly', format: :json
      get 'courses_languages', format: :json
      get 'courses_language_monthly', format: :json
      get 'courses_language_weekly', format: :json
    end
  end
  resources :courses, only: [:index, :create, :edit, :update] do
    post 'sign_up', on: :member
    get '(/lang/:language)(/teacher/:teacher)(/:year(/:month(/:day(/:hour))))',
      to: 'courses#index',
      on: :collection,
      language: /\w+/,
      teacher: /\w+/,
      year: /\d+/,
      month: /\d+/,
      day: /\d+/,
      hour: /\d+/
  end
  resources :tickets, only: [:new, :create] do
    collection do
      get 'checkout', format: :json
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
    collection do
      post 'add_language'
      get 'action_required_courses'
      get 'future_courses'
    end
  end
  resources :stripe, only: [] do
    collection do
      get 'connect'
      post 'on_event'
    end
  end
  root to: "users#dashboard"
end
