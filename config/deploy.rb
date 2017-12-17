# config valid for current version and patch releases of Capistrano
lock "~> 3.10.1"

set :application, "readybase"
set :repo_url, "git@github.com:danallison/readybase.git"

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, "/home/deploy/readybase"

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# append :linked_files, "config/database.yml", "config/secrets.yml"
set :linked_files, fetch(:linked_files, []).push('config/puma.rb')

# Default value for linked_dirs is []
# append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system"
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system', 'public/uploads')

# Default value for default_env is {}
set :default_env, { RAILS_ENV: 'production' }
set :rails_env, 'production'

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
# set :keep_releases, 5

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure

set :rvm_custom_path, "/usr/share/rvm"
set :bundle_gemfile, "#{current_path}/Gemfile"

# Puma:
puma_conf_path = "#{shared_path}/config/puma.rb"
set :puma_conf, puma_conf_path
set :puma_threads, [1, 1]
set :puma_workers, 1
set :puma_restart_command, "bundle exec puma -C #{puma_conf_path}"
set :puma_control_app, true
set :puma_init_active_record, true
set :nginx_config_name, "readybase"

namespace :deploy do
  before 'check:linked_files', 'puma:config'
  before 'check:linked_files', 'puma:nginx_config'
  after 'puma:smart_restart', 'nginx:restart'
end
