module Opener
  class OpinionDetectorBasic
    ##
    # Class that detects opinions in a given input KAF file.
    #
    class Processor < BaseProcessor

      def opinions
        return @opinions if @opinions

      end

      def set_accumulated_strength
        terms.each.with_index do |term, i|
        end
      end

    end
  end
end
