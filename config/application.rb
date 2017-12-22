require_relative 'boot'

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "action_cable/engine"
# require "sprockets/railtie"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module ReadyBase
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.autoload_paths += %W(#{config.root}/app/services)

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true
    config.middleware.insert_after ActionDispatch::Callbacks, ActionDispatch::Cookies

    # SecureRandom.base58(24)
    config.meta_app_id = 'yWWyBRWrvvhZ3hH7JAoPNmXx'
    # If the json file below changes, Rails might not pick up the change unless this rb file changes also.
    # So, here's random string you can change to get Rails to reload the file: 0ded54d7fbbbbd5c805548b7ae545e6
    config.default_app_config = JSON.parse(File.read("#{Rails.root}/config/default_app_config.json"))
  end
end
