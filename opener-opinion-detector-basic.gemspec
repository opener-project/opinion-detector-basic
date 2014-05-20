require File.expand_path('../lib/opener/opinion_detector_basic/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name        = 'opener-opinion-detector-basic'
  gem.version     = Opener::OpinionDetectorBasic::VERSION
  gem.authors     = ['development@olery.com']
  gem.summary     = 'Basic Opinion Detector.'
  gem.description = gem.summary
  gem.homepage    = 'http://opener-project.github.com/'

  gem.required_ruby_version = '>= 1.9.2'

  gem.files = Dir.glob([
    'core/site-packages/pre_build/**/*',
    'core/packages/*',
    'core/vendor/src/**/*',
    'core/*',
    'ext/**/*',
    'lib/**/*',
    'config.ru',
    '*.gemspec',
    '*_requirements.txt',
    'README.md'
  ]).select { |file| File.file?(file) }

  gem.executables = Dir.glob('bin/*').map { |file| File.basename(file) }

  gem.add_dependency 'opener-build-tools', ['>= 0.2.7']
  gem.add_dependency 'rake'
  gem.add_dependency 'sinatra'
  gem.add_dependency 'httpclient'
  gem.add_dependency 'puma'
  gem.add_dependency 'opener-webservice'

  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'cucumber'
end
