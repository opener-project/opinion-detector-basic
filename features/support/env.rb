require_relative '../../lib/opener/opinion_detector_basic'
require 'rspec'

ENV['OPINION_LEGACY'] = 'true'

def kernel
  return Opener::OpinionDetectorBasic.new(:no_time => true, :pretty => true)
end

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
  end

  config.mock_with :rspec do |c|
    c.syntax = [:should, :expect]
  end
end
