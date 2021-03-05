module Opener
  class OpinionDetectorBasic
    ##
    # Class that detects opinions in a given input KAF file.
    #
    class Processor < BaseProcessor

      ##
      # Processes the input and returns the new KAF output.
      # @return [String]
      #
      def process
        index = 1
        opinions.each do |opinion|
          add_opinion(opinion, index)
          index += 1
        end

        super
      end


    end
  end
end
