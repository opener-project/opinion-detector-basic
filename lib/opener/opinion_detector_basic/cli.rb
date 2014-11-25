module Opener
  class OpinionDetectorBasic
    ##
    # CLI wrapper around {Opener::OpinionDetectorBasic} using Slop.
    #
    # @!attribute [r] parser
    #  @return [Slop]
    #
    class CLI
      attr_reader :parser

      def initialize
        @parser = configure_slop
      end

      ##
      # @param [Array] argv
      #
      def run(argv = ARGV)
        parser.parse(argv)
      end

      ##
      # @return [Slop]
      #
      def configure_slop
        return Slop.new(:strict => false, :indent => 2, :help => true) do
          banner 'Usage: opinion-detector-basic [OPTIONS]'

          separator <<-EOF.chomp

About:

    Rule based opinion detection for various languages such as Dutch and
    English. This command reads input from STDIN.

Example:

    cat some_file.kaf | opinion-detector-basic
          EOF

          separator "\nOptions:\n"

          on :v, :version, 'Shows the current version' do
            abort "opinion-detector-basic v#{VERSION} on #{RUBY_DESCRIPTION}"
          end

          run do |opts, args|
            detector = OpinionDetectorBasic.new(
              :args   => args,
              :domain => opts[:domain]
            )

            input = STDIN.tty? ? nil : STDIN.read

            puts detector.run(input)
          end
        end
      end
    end # CLI
  end # OpinionDetectorBasic
end # Opener
