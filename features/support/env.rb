require_relative '../../lib/opener/opinion_detector_basic'
require 'rspec'
require 'tempfile'

def kernel_root
  File.expand_path("../../../", __FILE__)
end

def kernel(language)
  return Opener::OpinionDetectorBasic.new(
    :language => language,
    :args => ['--no-time']
  )
end

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
  end

  config.mock_with :rspec do |c|
    c.syntax = [:should, :expect]
  end
end
