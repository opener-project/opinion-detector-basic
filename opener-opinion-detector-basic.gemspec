require File.expand_path('../lib/opener/opinion_detector_basic/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name        = 'opener-opinion-detector-basic'
  gem.version     = Opener::OpinionDetectorBasic::VERSION
  gem.authors     = ['development@olery.com']
  gem.summary     = 'Basic Opinion Detector.'
  gem.description = gem.summary
  gem.homepage    = 'http://opener-project.github.com/'
  gem.license     = 'Apache 2.0'

  gem.required_ruby_version = '>= 1.9.2'

  gem.files = Dir.glob([
    'lib/**/*',
    'config.ru',
    '*.gemspec',
    'README.md',
    'LICENSE.txt',
    'exec/**/*',
    'task/*'
  ]).select { |file| File.file?(file) }

  gem.executables = Dir.glob('bin/*').map { |file| File.basename(file) }

  gem.add_dependency 'opener-daemons', '~> 2.2'
  gem.add_dependency 'opener-webservice', '~> 2.1'
  gem.add_dependency 'opener-core', '~> 2.2'

  gem.add_dependency 'oga', ['~> 1.0', '>= 1.3.1']

  gem.add_development_dependency 'rspec', '~> 3.0'
  gem.add_development_dependency 'cucumber'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'benchmark-ips', '~> 2.0'
end
