gem 'slop', '~> 3.0'

require 'slop'
require 'hashie'
require 'nokogiri'

require 'rexml/document'
require 'rexml/formatters/pretty'

require_relative 'opinion_detector_basic/kaf/document'
require_relative 'opinion_detector_basic/kaf/term'
require_relative 'opinion_detector_basic/kaf/opinion'

require_relative 'opinion_detector_basic/version'
require_relative 'opinion_detector_basic/cli'
require_relative 'opinion_detector_basic/base_processor'
require_relative 'opinion_detector_basic/processor'
require_relative 'opinion_detector_basic/legacy_processor'

module Opener
  ##
  # Rule based opinion detector.
  #
  # @!attribute [r] args
  #  @return [Array]
  #
  # @!attribute [r] options
  #  @return [Hash]
  #
  class OpinionDetectorBasic
    attr_reader :args, :options

    ##
    # @param [Hash] options
    #
    # @option options [Array] :args Command-line arguments to pass to the
    #  underlying Python kernel.
    #
    def initialize(options = {})
      @args    = options.delete(:args) || []
      @options = options
      @klass   = if ENV['OPINION_LEGACY'] then LegacyProcessor else Processor end
    end

    ##
    # Processes the input KAF document.
    #
    # @param [String] input
    # @return [String]
    #
    def run input, params = {}
      @klass.new(input, options).process
    end

  end
end


