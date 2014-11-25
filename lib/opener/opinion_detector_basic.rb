require 'open3'
require 'slop'

require_relative 'opinion_detector_basic/version'
require_relative 'opinion_detector_basic/cli'

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
    # Builds the command used to execute the kernel.
    #
    # @param [Array] args Commandline arguments passed to the command.
    #
    def command
      return "#{adjust_python_path} python -E #{kernel} #{args.join(' ')}"
    end

    ##
    # Processes an input KAF document and returns the results as a new KAF
    # document.
    #
    # @param [String] input
    # @return [String]
    #
    def run(input)
      stdout, stderr, process = capture(input)

      raise stderr unless process.success?

      return stdout
    end

    protected

    ##
    # @return [String]
    #
    def adjust_python_path
      site_packages =  File.join(core_dir, 'site-packages')

      return "env PYTHONPATH=#{site_packages}:$PYTHONPATH"
    end

    ##
    # capture3 method doesn't work properly with Jruby, so
    # this is a workaround
    #
    def capture(input)
      Open3.popen3(*command.split(" ")) {|i, o, e, t|
        out_reader = Thread.new { o.read }
        err_reader = Thread.new { e.read }
        i.write input
        i.close
        [out_reader.value, err_reader.value, t.value]
      }
    end

    ##
    # @return [String]
    #
    def core_dir
      return File.expand_path('../../../core', __FILE__)
    end

    ##
    # @return [String]
    #
    def kernel
      return File.join(core_dir, 'opinion_detector_basic_multi.py')
    end

    ##
    # @return the language from the KAF
    #
    def language(input)
      document = Nokogiri::XML(input)

      return document.at('KAF').attr('xml:lang')
    end
  end # OpinionDetectorBasic
end # Opener
