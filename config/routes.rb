Rails.application.routes.draw do
  meta_app_constraint = lambda {|r| r.headers['X-App-ID'] == Rails.application.config.meta_app_id }
  scope :api do
    scope :v1 do
      resources :apps, constraints: meta_app_constraint
      resources :users do
        resources :apps, constraints: meta_app_constraint
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
