Rails.application.routes.draw do
  resources :work_hours
  resources :assignments
  resources :teaching_assistants
  resources :courses, shallow: true do
    resources :assignments
    resources :work_hours
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "courses#index"
end
