Rails.application.routes.draw do
  scope :api do
    scope :v1 do
      resources :users do
        resources :users
        resources :app_objects, path: 'objects'
        resources :app_objects, path: ':object_type'
      end
      resources :sessions
      resource :sessions
      resources :app_objects, path: 'objects' do
        resources :users
        resources :app_objects, path: 'objects'
        resources :app_objects, path: ':object_type'
      end
      resources :app_objects, path: ':object_type'
      resources :app_objects, path: ':associated_object_type' do
        resources :users
        resources :app_objects, path: 'objects'
        resources :app_objects, path: ':object_type'
      end
    end
  end
end
