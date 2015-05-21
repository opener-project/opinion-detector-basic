module Opener
  class OpinionDetectorBasic
    class Term
      attr_reader :node, :sentence, :is_conjunction
      attr_accessor :use, :accumulated_strength, :list_ids
      
      def initialize(node, document, language)
        @node                 = node
        @sentence             = get_sentence(document)
        @use                  = true
        @accumulated_strength = strength
        @list_ids             = [id]
        @is_conjunction       = is_conjunction?(language)
      end
      
      ##
      # Returns the term id.
      #
      # @return [String]
      #
      def id
        @id ||= node.get('tid')
      end
      
      ##
      # Returns the lemma of the term.
      # 
      # @return [String]
      #
      def lemma
        @lemma ||= node.get('lemma')
      end
      
      ##
      # Returns the part of speech of the term.
      #
      # @return [String]
      #
      def pos
        @pos ||= node.get('pos')
      end
      
      ##
      # Returns the sentiment modifier type if it exists.
      #
      # @return [String|NilClass]
      #
      def sentiment_modifier
        @sentiment_modifier ||= if sentiment = node.xpath('sentiment').first
          sentiment.get('sentiment_modifier')
        end
      end
      
      ##
      # Returns the polarity of the term if it exists.
      #
      # @return [String|NilClass]
      #
      def polarity
        @polarity ||= if sentiment = node.xpath('sentiment').first
          sentiment.get('polarity')
        end
      end
      
      ##
      # Returns the actual word ids that construct the lemma.
      #
      # @return [Array]
      #
      def target_ids
        @target_ids ||= node.xpath('span/target').map {|target| target.get('id')}
      end
      
      ##
      # Returns the strength of the term depending on its type.
      #
      # @return [Integer]
      #
      def strength
        if polarity == "positive"
          return 1
        elsif polarity == "negative"
          return -1
        end
        
        if is_intensifier?
          return 2
        elsif is_shifter?
          return -1
        end
        
        return 0
      end
      
      ##
      # Returns the sentence id that the term belongs to in the document.
      #
      # @return [String]
      #
      def get_sentence(document)
        document
        .xpath("KAF/text/wf[@wid='#{target_ids.first}']")
        .first
        .get('sent')
      end
      
      ##
      # Checks if a term is an intensifier.
      #
      # @return [TrueClass|FalseClass]
      #
      def is_intensifier?
        sentiment_modifier == "intensifier"
      end
      
      ##
      # Checks if a term is a shifter.
      #
      # @return [TrueClass|FalseClass]
      #
      def is_shifter?
        sentiment_modifier == "shifter"
      end
      
      ##
      # Checks if a term is an expression.
      #
      # @return [TrueClass|FalseClass]
      #
      def is_expression?
        use && !!polarity
      end
      
      ##
      # Checks if a term is a conjunction.
      #
      # @return [TrueClass|FalseClass]
      #
      def is_conjunction?(language)
        conjunctions[language].include?(lemma)
      end
      
      ##
      # Map of conjunctions per language code
      #
      # @return [Hash]
      #
      def conjunctions
        {
          'nl' => [',','en'],
          'en' => [',','and'],
          'es' => [',','y','e'],
          'it' => [',','e','ed'],
          'de' => [',','und'],
          'fr' => [',','et']         
        }
      end
    end # Term
  end # OpinionDetectorBasic
end # Opener