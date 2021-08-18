module Opener
  class OpinionDetectorBasic
    module Kaf
      class Term

        attr_reader :document
        attr_reader :node, :sentence, :is_conjunction

        attr_accessor :use, :accumulated_strength, :list_ids

        # Map of conjunctions per language code
        # Deprecated
        CONJUNCTIONS = {
          'nl' => %w{, en},
          'en' => %w{, and},
          'es' => %w{, y e},
          'pt' => %w{, e},
          'it' => %w{, e ed},
          'de' => %w{, und},
          'fr' => %w{, et},
        }

        def initialize node, document, language
          @document             = document
          @node                 = node
          @sentence             = get_sentence document
          @use                  = true
          @accumulated_strength = strength
          @list_ids             = [id]
          @is_conjunction       = is_conjunction? language
        end

        ##
        # Returns the term id.
        #
        # @return [String]
        #
        def id
          @id ||= node.attr :tid
        end

        ##
        # Returns the lemma of the term.
        #
        # @return [String]
        #
        def lemma
          @lemma ||= node.attr :lemma
        end

        ##
        # Returns the head of the term.
        #
        # @return [String]
        #
        def head
          @head ||= node.attr(:head).to_i
        end

        def head_term
          return if root?
          document.terms[head-1]
        end

        def root?
          head == 0
        end

        ##
        # Returns the part of speech of the term.
        #
        # @return [String]
        #
        def pos
          @pos ||= node.attr('pos')
        end

        def xpos
          @xpos ||= node.attr('xpos')
        end

        def lexicon_id
          @lexicon_id ||= node.attr('lexicon-id')
        end

        ##
        # Returns the sentiment modifier type if it exists.
        #
        # @return [String|NilClass]
        #
        def sentiment_modifier
          @sentiment_modifier ||=
            first_sentiment ? first_sentiment.attr('sentiment_modifier') : nil
        end

        ##
        # Returns the polarity of the term if it exists.
        #
        # @return [String|NilClass]
        #
        def polarity
          @polarity ||= first_sentiment ? first_sentiment.attr('polarity') : nil
        end

        ##
        # Returns the actual word ids that construct the lemma.
        #
        # @return [Array]
        #
        def target_ids
          @target_ids ||= node.xpath('span/target')
            .map { |target| target.attr('id') }
        end

        ##
        # Returns the strength of the term depending on its type.
        #
        # @return [Integer]
        #
        def strength
          return  1 if polarity == 'positive'
          return -1 if polarity == 'negative'
          return  2 if is_intensifier?
          return -1 if is_shifter?
          return  0
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
          .attr('sent')
        end

        ##
        # Checks if a term is an intensifier.
        #
        # @return [TrueClass|FalseClass]
        #
        def is_intensifier?
          sentiment_modifier == 'intensifier'
        end

        ##
        # Checks if a term is a shifter.
        #
        # @return [TrueClass|FalseClass]
        #
        def is_shifter?
          sentiment_modifier == 'shifter'
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
        # Comma is identified as conjunction by default
        # Sometimes, comma comes with space after it
        #
        def is_conjunction?(language)
          pos == 'J' || xpos == ',' || lemma == ',' || CONJUNCTIONS[language]&.include?(lemma)
        end

        private

        # @return [Oga::XML::Element]
        def first_sentiment
          @first_sentiment ||= node.at :sentiment
        end

      end
    end
  end
end
