Rails.application.routes.draw do
  scope :api do
    scope :v1 do
      resources :users
      resources :sessions
      resources :apps do
        resource :sessions
        resources :users
      end
    end
  end
end
