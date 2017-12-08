Rails.application.routes.draw do
  scope :api do
    scope :v1 do
      resource :sessions
      resources :users
    end
  end
end
