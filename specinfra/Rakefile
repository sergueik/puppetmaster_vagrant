require "bundler/gem_tasks"
begin
  require "rspec/core/rake_task"
  require "octorelease"
rescue LoadError
end

if defined?(RSpec)
  task :spec => 'spec:all'

  namespace :spec do
    task :all => [ :command ]

    RSpec::Core::RakeTask.new(:command) do |t|
      t.pattern = "spec/command/**/*.rb"
    end
  end
end
