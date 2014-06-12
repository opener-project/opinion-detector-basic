desc 'Updates the Git submodules'
task :submodules do
  sh 'git submodule init'
  sh 'git submodule update'
end
