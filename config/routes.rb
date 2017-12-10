Rails.application.routes.draw do
  scope :api do
    scope :v1 do
      resources :users do
        resources :app_objects, path: 'objects'
      end
      resources :sessions
      resources :app_objects, path: 'objects' do
        resources :users
        resources :app_objects, path: 'objects'
      end
      resources :apps do
        resources :users do
          resources :app_objects, path: 'objects'
        end
        resource :sessions
        resources :app_objects, path: 'objects' do
          resources :users
          resources :app_objects, path: 'objects'
        end
      end
    end
  end
end
