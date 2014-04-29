require 'open3'

require_relative 'basic/version'

module Opener
  module OpinionDetectors
    class ModelsMissing < StandardError; end

    ##
    # The basic Opinion detector.
    #
    # @!attribute [r] args
    #  @return [Array]
    # @!attribute [r] options
    #  @return [Hash]
    #
    class Basic
      attr_reader :args, :options, :conf_file

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
        return Open3.capture3(*command.split(" "), :stdin_data => input)
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
      # @return [String]
      #
      def core_dir
        return File.expand_path('../../../../core', __FILE__)
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

    end # Basic
  end # OpinionDetectors
end # Opener
