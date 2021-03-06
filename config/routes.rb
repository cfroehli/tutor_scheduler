# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users, path: 'auth', path_names: { sign_in: 'login', sign_out: 'logout', sign_up: 'register' }
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
  resources :courses, only: %i[index create edit update] do
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
  resources :tickets, only: %i[new create] do
    collection do
      get 'checkout', format: :json
      get 'order_success'
      get 'order_cancel'
    end
  end
  resources :teached_languages, only: [] do
    member do
      get 'activate'
      get 'deactivate'
    end
  end
  resources :teachers, except: %i[new create destroy] do
    collection do
      post 'add_language'
      get 'action_required_courses'
      get 'future_courses'
    end
  end
  resources :stripe, only: %i[new create] do
    post 'on_event', on: :collection
    post 'cancel_subscription', on: :collection
  end
  root to: 'users#dashboard'
end
