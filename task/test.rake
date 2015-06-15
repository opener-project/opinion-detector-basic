desc 'Runs the tests'
task :test do
  sh('cucumber features')
end
