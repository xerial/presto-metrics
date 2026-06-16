require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

desc "Open an irb session preloaded with this library"
task :console do
  sh "irb -I lib -r presto/metrics.rb"
end

desc "Bump version, commit, tag, and push to trigger CI release. Usage: rake bump[X.Y.Z]"
task :bump, [:version] do |_, args|
  version = args[:version] or raise "Usage: rake bump[X.Y.Z]"

  file = "lib/presto/metrics/version.rb"
  content = File.read(file).gsub(/VERSION = ".*"/, %(VERSION = "#{version}"))
  File.write(file, content)

  sh "git add #{file}"
  sh "git commit -m 'chore: bump version to #{version}'"
  sh "git tag v#{version}"
  sh "git push origin master"
  sh "git push origin v#{version}"
end
