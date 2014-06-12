build_dir = File.expand_path('../../core/vendor/build', __FILE__)
bin_dir   = File.join(build_dir, 'bin')

# Names of the various files to build. We're using variables here since they're
# a bit too painful to type multiple times.
liblbfgs     = "core/vendor/build/lib/liblbfgs.#{RbConfig::CONFIG['DLEXT']}"
crfsuite     = 'core/vendor/build/bin/crfsuite'
svm_classify = 'core/vendor/build/bin/svm_classify'
svm_learn    = 'core/vendor/build/bin/svm_learn'

file liblbfgs do
  Dir.chdir('core/vendor/src/liblbfgs') do
    sh "./configure --prefix=#{build_dir}"
    sh 'make && make install && make distclean'
  end
end

file crfsuite => liblbfgs do
  Dir.chdir('core/vendor/src/crfsuite') do
    sh "./configure --prefix=#{build_dir} --with-liblbfgs=#{build_dir}"
    sh 'make && make install && make distclean'
  end
end

file svm_classify do
  Dir.chdir('core/vendor/src/svm_light') do
    sh 'make'
    sh "cp -f svm_classify svm_learn #{bin_dir}"
    sh 'make clean'
  end
end

namespace :c do
  desc 'Compiles the vendored C code'
  task :compile => [crfsuite, svm_classify]
end
