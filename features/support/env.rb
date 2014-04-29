require_relative '../../lib/opener/opinion_detectors/basic'
require 'rspec/expectations'
require 'tempfile'

def kernel_root
  File.expand_path("../../../", __FILE__)
end

def kernel(language)
  return Opener::OpinionDetectors::Basic.new(
    :language => language,
    :args => ['--no-time']
  )
end
