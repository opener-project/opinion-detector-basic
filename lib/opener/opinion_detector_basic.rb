gem 'slop', '~> 3.0'

require 'slop'
require 'nokogiri'

require 'rexml/document'
require 'rexml/formatters/pretty'

require_relative 'opinion_detector_basic/version'
require_relative 'opinion_detector_basic/cli'
require_relative 'opinion_detector_basic/processor'

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
    end

    ##
    # Processes the input KAF document.
    #
    # @param [String] input
    # @return [String]
    #
    def run input, params = {}
      return Processor.new(input, options).process
    end

  end
end


