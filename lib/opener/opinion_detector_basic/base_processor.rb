module Opener
  class OpinionDetectorBasic
    class BaseProcessor

      attr_accessor :document
      attr_reader :terms, :sentences

      ##
      # @param [String|IO] file The KAF file/input to process.
      # @param [Hash] options. Options for timestamp and including strength to
      # opinions.
      # @param [TrueClass|FalseClass] pretty Enable pretty formatting, disabled
      #  by default due to the performance overhead.
      #
      def initialize file, options = {}
        @document  = Kaf::Document.new file, options
        @terms     = @document.terms
        @sentences = @document.sentences
      end

      ##
      # Processes the input and returns the new KAF output.
      # @return [String]
      #
      def process
        document.add_opinions_layer
        opinions.each.with_index do |opinion, index|
          document.add_opinion opinion, index+1
        end

        document.add_linguistic_processor

        if document.pretty then pretty_print document else document.to_xml end
      end

      ##
      # Format the output document properly.
      #
      # TODO: this should be handled by Oga in a nice way.
      #
      # @return [String]
      #
      def pretty_print(document)
        doc = REXML::Document.new document.to_xml
        doc.context[:attribute_quote] = :quote
        out = ""
        formatter = REXML::Formatters::Pretty.new
        formatter.compact = true
        formatter.write(doc, out)

        out.strip
      end

    end
  end
end
