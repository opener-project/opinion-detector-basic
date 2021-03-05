module Opener
  class OpinionDetectorBasic
    ##
    # Class that detects opinions in a given input KAF file.
    #
    class LegacyProcessor < BaseProcessor

      def opinions
        unless @opinions
          set_accumulated_strength
          apply_modifiers
          apply_conjunctions

          ##
          # Initialize opinions with their expressions.
          #
          @opinions = document.terms.map do |term|
            if term.is_expression? && term.accumulated_strength != 0
              Kaf::Opinion.new(term)
            end
          end.compact

          ##
          # Obtain targets for each opinion.
          #
          @opinions.each do |opinion|
            opinion.obtain_targets(sentences)
          end

          ##
          # Obtain holders for each opinion.
          #
          @opinions.each do |opinion|
            opinion.obtain_holders(sentences, document.language)
          end
        end

        @opinions
      end

      protected

      ##
      # The strength of a term depends heavily on the type of the previous
      # one. For example if the previous one is a shifter, it needs
      # to be multiplied. If it's an intensifier, it needs to be
      # added (or subtracted depending on the strength of the previous
      # term) etc.
      #
      def set_accumulated_strength
        symbol    = :+
        terms_count = terms.count
        terms.each.with_index do |term, i|
          if i+1 < terms_count
            if terms[i+1].is_shifter?
              if term.accumulated_strength != 0
                terms[i+1].accumulated_strength *= term.accumulated_strength
                terms[i+1].list_ids += term.list_ids
                term.use = false
                symbol = terms[i+1].accumulated_strength > 0 ? :+ : :-
              else
                symbol = :*
              end
            elsif terms[i+1].is_intensifier?
              terms[i+1].accumulated_strength = term.accumulated_strength.send(symbol, terms[i+1].accumulated_strength)
              term.use = false
              symbol = terms[i+1].accumulated_strength > 0 ? :+ : :-
              if term.accumulated_strength != 0
                terms[i+1].list_ids += term.list_ids
              end
            else
              symbol = terms[i+1].accumulated_strength >= 0 ? :+ : :-
            end
          end
        end
      end

      ##
      # Apply strength to the next term after a shifter or intensifier.
      #
      def apply_modifiers
        terms_count = terms.count
        terms.each.with_index do |term, i|
          if i+1 < terms_count
            if term.use && (term.is_shifter? || term.is_intensifier?)
              terms[i+1].accumulated_strength *= term.accumulated_strength
              terms[i+1].list_ids += term.list_ids
              term.use = false
            end
          end
        end
      end

      ##
      # Ignore conjunctions when applying strength.
      #
      def apply_conjunctions
        terms_count = terms.count
        i = 0
        while i < terms_count
          if terms[i].use && terms[i].accumulated_strength != 0
            used     = [i]
            list_ids = terms[i].list_ids
            strength = terms[i].accumulated_strength
            terms[i].use = false
            j = i+1
            while true
              if j >= terms_count
                break
              end

              if terms[j].is_conjunction
                terms[j].use = false
                j += 1
              elsif terms[j].use && terms[j].accumulated_strength != 0
                list_ids += terms[j].list_ids
                used << j
                terms[j].use = false
                strength += terms[j].accumulated_strength
                j += 1
              else
                break
              end
            end
            last_used = used.last
            terms[last_used].accumulated_strength = strength
            terms[last_used].list_ids = list_ids
            terms[last_used].use = true
            i = j
          end
          i += 1
        end
      end

    end
  end
end
