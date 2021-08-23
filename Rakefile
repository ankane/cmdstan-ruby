require "bundler/gem_tasks"
require "rake/testtask"

task default: :test
Rake::TestTask.new do |t|
  t.libs << "test"
  t.pattern = "test/**/*_test.rb"
end

# rake clean excludes **/core by default
CLEAN.exclude("**/Eigen/Core")
CLEAN.include("tmp/cmdstan")
