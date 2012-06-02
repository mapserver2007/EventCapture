require 'rspec/core/rake_task'

task:default => [:spec, :github_push, :heroku_deploy, :heroku_open]

Rspec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rspec_opts = ['-cfs']
end

task :github_push => [:spec] do
  sh 'git push origin master'
end

task :heroku_deploy => [:github_push] do
  sh 'git push heroku master'
end

task :heroku_open => [:heroku_deploy] do
  sh 'heroku open'
end