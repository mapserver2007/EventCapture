task:default => [:spec]

require 'rspec/core/rake_task'
Rspec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rspec_opts = ['-f html > spec/rspec.html']
end

