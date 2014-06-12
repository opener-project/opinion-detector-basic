require File.expand_path('../lib/opener/opinion_detector_basic/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name        = 'opener-opinion-detector-basic'
  gem.version     = Opener::OpinionDetectorBasic::VERSION
  gem.authors     = ['development@olery.com']
  gem.summary     = 'Basic Opinion Detector.'
  gem.description = gem.summary
  gem.homepage    = 'http://opener-project.github.com/'
  gem.extensions  = ['ext/hack/Rakefile']

  gem.required_ruby_version = '>= 1.9.2'

  gem.files = Dir.glob([
    'core/vendor/src/**/*',
    'core/*',
    'ext/**/*',
    'lib/**/*',
    'config.ru',
    '*.gemspec',
    '*_requirements.txt',
    'README.md',
    'exec/**/*',
    'task/*'
  ]).select { |file| File.file?(file) }

  gem.executables = Dir.glob('bin/*').map { |file| File.basename(file) }

  gem.add_dependency 'rake'
  gem.add_dependency 'sinatra'
  gem.add_dependency 'httpclient'
  gem.add_dependency 'puma'
  gem.add_dependency 'opener-daemons'
  gem.add_dependency 'opener-core', ['>= 0.1.2']
  gem.add_dependency 'opener-webservice'
  gem.add_dependency 'nokogiri'
  gem.add_dependency 'cliver'

  gem.add_development_dependency 'rspec', '~> 3.0'
  gem.add_development_dependency 'cucumber'
end
