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
      resources :app_objects, path: ':plural_object_type'
      resources :app_objects, path: ':associated_plural_object_type' do
        resources :app_objects, path: ':plural_object_type'
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
