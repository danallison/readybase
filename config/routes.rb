Rails.application.routes.draw do
  
  # DBs
  post   "/api/v1/db", to: "ready_databases#create", as: :create_ready_db
  get    "/api/v1/db", to: "ready_databases#index", as: :ready_dbs
  get    "/api/v1/db/:id", to: "ready_databases#show", as: :ready_db
  put    "/api/v1/db/:id", to: "ready_databases#update", as: :update_ready_db
  delete "/api/v1/db/:id", to: "ready_databases#destroy", as: :destroy_ready_db

  # Top-level resources
  post   "/api/v1/db/:db_id/:resource_type", to: "ready_resources#create", as: :create_ready_resource
  get    "/api/v1/db/:db_id/:resource_type", to: "ready_resources#index", as: :ready_resources
  get    "/api/v1/db/:db_id/:resource_type/:id", to: "ready_resources#show", as: :ready_resource
  put    "/api/v1/db/:db_id/:resource_type/:id", to: "ready_resources#update", as: :update_ready_resource
  delete "/api/v1/db/:db_id/:resource_type/:id", to: "ready_resources#destroy", as: :destroy_ready_resource
  
  # TODO - second and third level resources

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
