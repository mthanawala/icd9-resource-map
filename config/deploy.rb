######
# RVM bootstrap
#$:.unshift(File.expand_path('./lib', ENV['rvm_path']))
require 'rvm/capistrano'
set :rvm_ruby_string, '2.1.2'
set :rvm_type, :system
set :keep_releases, 3

# bundler bootstrap
require 'bundler/capistrano'
set :bundle_flags, '--deployment'

# main details
set :application, "icd9_resource_map"
set :user, ENV['USER']

desc "Run tasks in demo2 enviroment."
task :demo2 do
  # Demo nodes
  role :web, "demo2.healthloop.com"
  role :app, "demo2.healthloop.com"
  role :worker, "demo2.healthloop.com"
  role :db, "demo2.healthloop.com", :primary => true
  set :deploy_to, "/var/www/icd9_resource_map/demo"
  set :branch, "master"
  set :rails_env, "production"
end

# server details
default_run_options[:pty] = true
ssh_options[:forward_agent] = true
set :use_sudo, false
set :normalize_asset_timestamps, false

# repo details
set :scm, :git
set :scm_username, ENV['USER']
set :scm_verbose, true
set :repository, "git@github.com:mthanawala/icd9-resource-map.git"
set :git_enable_submodules, 1

# tasks
namespace :deploy do
  task :start, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
  end

  task :stop, :roles => :app do
    # Do nothing.
  end

  desc "Restart Application"
  task :restart, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
  end
end

namespace :remote do
  desc "Connects remotely to the database"
  task :console do
    server ||= find_servers_for_task(current_task).first
    exec %{ssh #{ENV['USER']}@#{server} -t "/usr/local/rvm/bin/rvm-shell -c 'cd #{current_path} && bundle exec rails c #{rails_env}'"}
  end

  task :sandbox do
    server ||= find_servers_for_task(current_task).first
    exec %{ssh #{ENV['USER']}@#{server} -t "/usr/local/rvm/bin/rvm-shell -c 'cd #{current_path} && bundle exec rails c -s #{rails_env}'"}
  end

  desc "Connects remotely to the database"
  task :dbconsole do
    server ||= find_servers_for_task(current_task).first
    exec %{ssh #{ENV['USER']}@#{server} -t "/usr/local/rvm/bin/rvm-shell  -c 'cd #{current_path} && bundle exec rails dbconsole #{rails_env}'"}
  end
end

def get_env_var_or_ask(env_name, prompt, default=nil)
  if ENV[env_name]
    enviroment = ENV[env_name]
    puts "#{prompt}: #{enviroment}"
  else
    print "#{prompt}"
    print " (#{default}) " if default
    print ": "
    enviroment = $stdin.gets.chomp
    if enviroment.empty?
      enviroment = default
    end
  end

  return enviroment
end


before 'deploy' do
  branch = get_env_var_or_ask('BRANCH', "Branch", `git rev-parse --abbrev-ref HEAD`.chomp)
  ENV['BRANCH'] = branch
  set :branch, branch

  p "Deploying to #{fetch(:rails_env)} from branch: #{branch}"
end

# Automatically always run migrations, so we don't forget
after "deploy:update_code", "deploy:migrate"

# Automatically start delayed_job
after "deploy:restart", "deploy:cleanup"

after :deploy do
  run "chmod -R g+w #{release_path}/tmp"
end
