require 'bundler/setup'
require 'rspec/core/rake_task'

require 'stove/rake_task'
Stove::RakeTask.new

namespace :style do
  require 'foodcritic'
  desc 'Run Chef style checks'
  FoodCritic::Rake::LintTask.new(:chef)
end

desc 'Run all style checks'
task style: ['style:chef']

RSpec::Core::RakeTask.new(:unit) do |t|
  t.rspec_opts = [].tap do |a|
    a.push('--color')
    a.push('--format progress')
  end.join(' ')
end

desc 'Run all tests'
task test: [:unit]

# The default rake task should just run it all
task default: [:style, :test]
