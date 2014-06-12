require 'open3'

require_relative 'opinion_detector_basic/version'
require_relative 'opinion_detector_basic/error_layer'

module Opener


  ##
  # The basic Opinion detector.
  #
  # @!attribute [r] args
  #  @return [Array]
  # @!attribute [r] options
  #  @return [Hash]
  #
  class OpinionDetectorBasic
    attr_reader :args, :options

    def initialize(options = {})
      @args          = options.delete(:args) || []
      @options       = options
    end

    ##
    # Builds the command used to execute the kernel.
    #
    # @param [Array] args Commandline arguments passed to the command.
    #
    def command
      return "#{adjust_python_path} python -E -OO #{kernel} #{args.join(' ')}"
    end

    ##
    # Runs the command and returns the output of STDOUT, STDERR and the
    # process information.
    #
    # @param [String] input The input to tag.
    # @return [Array]
    #
    def run(input)
      begin
        capture(input)
        stdout, stderr, process = capture(input)
        raise stderr unless process.success?
        return stdout
        
      rescue Exception => error
        return ErrorLayer.new(input, error.message, self.class).add
      end
    end

    protected
    ##
    # @return [String]
    #
    def adjust_python_path
      site_packages =  File.join(core_dir, 'site-packages')
      "env PYTHONPATH=#{site_packages}:$PYTHONPATH"
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
      language = document.at('KAF').attr('xml:lang')
      return language
    end

  end # OpinionDetectorBasic
end # Opener
