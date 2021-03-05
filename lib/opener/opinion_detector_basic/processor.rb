module Opener
  class OpinionDetectorBasic
    ##
    # Class that detects opinions in a given input KAF file.
    #
    class Processor < BaseProcessor

      def opinions
        return @opinions if @opinions

        ##
        # Initialize opinions with their expressions.
        #
        @opinions = document.terms.map do |term|
          next unless term.is_expression? and term.accumulated_strength != 0
          Kaf::Opinion.new term
        end.compact

        set_accumulated_strength
      end

      def set_accumulated_strength
        terms.each.with_index do |term, i|
          head = term.head_term
          if head.is_shifter?
            term.accumulated_strength *= -1
            term.list_ids += term.list_ids
          elsif head.is_intensifier?
            term.accumulated_strength += head.accumulated_strength
            term.list_ids += term.list_ids
          else
          end
        end
      end

    end
  end
end
