task default: [:style, :lint, :spec, :test]

desc 'Run tests capable of running on circleci.'
task circleci: [:style, :lint] do
  sh 'chef exec rspec -r rspec_junit_formatter --format RspecJunitFormatter -o $CIRCLE_TEST_REPORTS/rspec/junit.xml'
end

desc 'Run rubocop against cookbook ruby files.'
task :style do
  sh 'chef exec rubocop'
end

desc 'Run foodcritic linter against cookbook.'
task :lint do
  sh 'chef exec foodcritic -X spec/ -f any .'
end

desc 'Run chefspec.'
task :spec do
  sh 'chef exec rspec --color'
end

desc 'Run test kitchen.'
task :test do
  sh 'chef exec kitchen test'
end
