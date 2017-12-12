Rails.application.routes.draw do
  scope :api do
    scope :v1 do
      resources :apps, constraints: lambda {|r| r.headers['X-App-ID'] == Rails.application.config.meta_app_id }
      resources :users do
        resources :app_objects, path: 'objects'
        resources :app_objects, path: ':plural_object_type'
      end
      resources :sessions
      resources :app_objects, path: 'objects' do
        resources :users
        resources :app_objects, path: 'objects'
      end
      resources :app_objects, path: ':plural_object_type'
      resources :app_objects, path: ':associated_plural_object_type' do
        resources :app_objects, path: 'objects'
        resources :app_objects, path: ':plural_object_type'
      end
    end
  end
end
