require "bundler/gem_tasks"
require "rspec/core/rake_task"

task :default => [:spec]

desc "Run the specs."
begin
  RSpec::Core::RakeTask.new do |t|
    t.rspec_opts = "--color --format documentation"
  end
rescue LoadError
# ignored
end
