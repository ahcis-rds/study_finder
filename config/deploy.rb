set :application, 'study_finder'
set :scm, :none
set :repository, "."

desc "Run on development server"
task :development do
  set :rails_env,   "development"
  set :location, "goldfish.ahc.umn.edu" # Web server url.
  role :web, location # Your HTTP server, Apache/etc
end

task :production do
  set :rails_env,   "production"
  set :location, "walleye.ahc.umn.edu" # Web server url.
  role :web, location # Your HTTP server, Apache/etc
end

set :user, "webcluster2" # Remote user name. Must be able to log in via SSH.
set :use_sudo, false # Remove or set the true if all commands should be run through sudo.
set :base_path, "/var/www/webapps/#{application}"
set :bundle_path, "#{base_path}/bundle"

# So can work with Pageant (i.e. public/private keys instead of password)
set :ssh_options, {:paranoid => false, :forward_agent => true}
set :deploy_to, "#{base_path}"
set :deploy_via, :copy # Copy the files across as an archive rather than using git on the remote machine.

require "bundler/capistrano"

# Load Bundler's Capistrano plugin
set :bundle_flags,    "--deployment"
set :bundle_without,  [:development, :test, :tools, :local]

desc "Fix permission"
task :fix_permissions, :roles => [ :web ] do
  run "chmod 775 -R #{release_path}"
end

after "figaro:symlink", :fix_permissions

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :web, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end

namespace :figaro do
  # desc "Symlink application.yml and database.yml to the release path"
  task :symlink do
    run "ln -sf #{shared_path}/database.yml #{release_path}/config/database.yml"
    run "ln -sf #{shared_path}/application.yml #{release_path}/config/application.yml"
  end

  after "deploy:finalize_update", "figaro:symlink"
end