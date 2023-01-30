# config valid for current version and patch releases of Capistrano
lock "3.17.1"

set :application, "study_finder"
set :repo_url, "git@github.umn.edu:hst-rds/study_finder_umn.git"
set :deploy_to, "/var/www/webapps/study_finder"
set :default_env, { path: "/opt/ruby31/bin:$PATH" }
set :passenger_restart_with_touch, true
set :branch, ENV.fetch("GIT_BRANCH", "master").sub(/^origin\//, "")

# If you need to exclude a 'local' environment use this (default is %w{development test}):
# set :bundle_without, %w{development test local}.join(' ')

# Default value for :linked_files is []
append :linked_files, "config/application.yml", "config/database.yml"

# Default value for linked_dirs is []
append :linked_dirs, "log", "storage"

set :keep_releases, 5


