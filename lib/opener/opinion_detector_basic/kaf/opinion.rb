module Opener
  class OpinionDetectorBasic
    module Kaf
      class Opinion

        attr_reader :term
        attr_accessor :left_candidates, :right_candidates, :target_ids, :holders

        # Opinion holders for each language code.
        OPINION_HOLDERS = {
          'nl' => %w[
            ik we wij ze zij jullie u hij het jij je mij
            me hem haar ons hen hun
          ],
          'en' => %w[i we he she they it you],
          'es' => %w[
            yo tu nosotros vosotros ellos ellas nosotras vosotras
          ],
          'it' => %w[io tu noi voi loro lei lui],
          'de' => %w[ich du wir ihr sie er],
          'fr' => %w[je tu lui elle nous vous ils elles],
        }

        def initialize term
          @term       = term
          @holders    = []
          @target_ids = []

          @left_candidates  = []
          @right_candidates = []
        end

        ##
        # Returns the term ids of the opinion expression.
        #
        # @return [Array]
        #
        def ids
          @ids ||= term.list_ids.sort
        end

        ##
        # Returns the sentence id of the opinion.
        #
        # @return [String]
        #
        def sentence
          @sentence ||= term.sentence
        end

        ##
        # Returns the strength of the opinion.
        #
        # @return [Integer]
        #
        def strength
          @strength ||= term.accumulated_strength
        end

        def lexicon_id
          @lexicon_id ||= term.lexicon_id
        end

        ##
        # Returns the polarity of the opinion.
        #
        # @return [String]
        #
        def polarity
          @polarity ||= if strength > 0
            'positive'
          elsif strength < 0
            'negative'
          else
            'neutral'
          end
        end

        ##
        # Obtain the opinion holders from the terms that belong to the same
        # sentence.
        #
        def obtain_holders(sentences, language)
          sentence_terms = sentences[sentence]
          sentence_terms.each do |term|
            if OPINION_HOLDERS[language]&.include?(term.lemma)
              @holders << term.id
              break
            end
          end
        end

        ##
        # Get the potential right and left candidates of the sentence and
        # decide which ones are the actual targets of the opinion
        #
        def obtain_targets(sentences)
          sentence_terms = sentences[sentence]
          max_distance = 3
          terms_count = sentence_terms.count

          index = -1
          sentence_terms.each_with_index do |term, i|
            if ids.include?(term.id)
              index = i
            end
          end

          unless index+1 >= terms_count
            min = index+1
            max = [index+1+max_distance,terms_count].min
            @right_candidates = filter_candidates(sentence_terms[min..max])
          end

          index = 0
          sentence_terms.each_with_index do |term, i|
            if ids.include?(term.id)
              index = i
              break # needed for left_candidates
            end
          end

          unless index == 0
            min = [0, index-1-max_distance].max
            max = index
            @left_candidates = filter_candidates(sentence_terms[min..max])
          end

          unless right_candidates.empty?
            candidate = right_candidates.first
            @target_ids << candidate.id
          end

          if target_ids.empty?
            list = mix_lists(right_candidates, left_candidates)
            list.each do |l|
              @target_ids << l.id
              break
            end
          end
        end

        protected

        ##
        # If there are no opinion targets, right and left candidates
        # are mixed into one list and the first one is picked as the target.
        #
        # @return [Array]
        #
        def mix_lists(lista, listb)
          list = []
          min = [lista.count, listb.count].min
          (0..min).each do |i|
            list << lista[i]
            list << listb[i]
            if lista.count > listb.count
              list << lista[min]
            elsif listb.count > lista.count
              list << listb[min]
            end
          end
          return list.compact
        end

        ##
        # Filters candidate terms depending on their part of speech and if
        # they are already part of the expression.
        #
        # @return [Hash]
        #
        def filter_candidates sentence_terms
          sentence_terms.select{|t| (t.pos == 'N' || t.pos == 'R') && !ids.include?(t.id)}
        end

      end
    end
  end
end
