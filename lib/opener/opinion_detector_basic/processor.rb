require_relative 'term'
require_relative 'opinion'

module Opener
  class OpinionDetectorBasic
    ##
    # Class that detects opinions in a given input KAF file.
    #
    class Processor
      attr_accessor :document, :timestamp, :opinion_strength, :pretty

      ##
      # @param [String|IO] file The KAF file/input to process.
      # @param [Hash] options. Options for timestamp and including strength to
      # opinions.
      # @param [TrueClass|FalseClass] pretty Enable pretty formatting, disabled
      #  by default due to the performance overhead.
      #
      def initialize(file, options = {})
        @document = Oga.parse_xml(file)

        @timestamp        = options[:timestamp]
        @opinion_strength = options[:opinion_strength]
        @pretty           = options[:pretty] || false

        raise 'Error parsing input. Input is required to be KAF' unless is_kaf?
      end

      ##
      # Processes the input and returns the new KAF output.
      # @return [String]
      #
      def process
        add_opinions_layer

        index = 1
        opinions.each do |opinion|
          add_opinion(opinion, index)
          index += 1
        end

        add_linguistic_processor

        pretty ? pretty_print(document) : document.to_xml
      end

      ##
      # Get the language of the input file.
      #
      # @return [String]
      #
      def language
        @language ||= document.at_xpath('KAF').get('xml:lang')
      end

      ##
      # Get the terms from the input file
      # @return [Hash]
      #
      def terms
        @terms ||= document.xpath('KAF/terms/term').map do |term|
          Term.new(term, document, language)
        end
      end

      ##
      # Get the opinions.
      #
      # @return [Hash]
      #
      def opinions
        unless @opinions
          set_accumulated_strength
          apply_modifiers
          apply_conjunctions

          ##
          # Initialize opinions with their expressions.
          #
          @opinions = terms.map do |term|
            if term.is_expression? && term.accumulated_strength != 0
              Opinion.new(term)
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
            opinion.obtain_holders(sentences, language)
          end
        end

        @opinions
      end

      ##
      # Remove the opinions layer from the KAF file if it exists and add a new
      # one.
      def add_opinions_layer
        existing = document.at_xpath('KAF/opinions')

        existing.remove if existing

        new_node('opinions', 'KAF')
      end

      ##
      # Adds the entire opinion in the KAF file.
      #
      def add_opinion(opinion, index)
        opinion_node = new_node("opinion", "KAF/opinions")
        opinion_node.set('oid', "o#{index.to_s}")

        unless opinion.holders.empty?
          opinion_holder_node = new_node("opinion_holder", opinion_node)
          add_opinion_element(opinion_holder_node, opinion.holders)
        end

        opinion_target_node = new_node("opinion_target", opinion_node)

        unless opinion.target_ids.empty?
          add_opinion_element(opinion_target_node, opinion.target_ids)
        end

        expression_node = new_node("opinion_expression", opinion_node)
        expression_node.set('polarity', opinion.polarity)
        expression_node.set('strength', opinion.strength.to_s)

        add_opinion_element(expression_node, opinion.ids)
      end

      ##
      # Method for adding opinion holders, targets and expressions.
      #
      def add_opinion_element(node, ids)
        lemmas = terms.select{|t| ids.include?(t.id)}.map(&:lemma).join(" ")
        comment = Oga::XML::Comment.new(:text => "#{lemmas}")
        node.children << comment
        span_node = new_node("span", node)

        ids.each do |id|
          target_node = new_node("target", span_node)
          target_node.set('id', id.to_s)
        end
      end

      ##
      # Add linguistic processor layer with basic information
      # (version, timestamp, description etc) in the KAF file.
      #
      def add_linguistic_processor
        description = 'Basic opinion detector with Pos'
        last_edited = '13may2015'
        version     = '2.0'

        node = new_node('linguisticProcessors', 'KAF/kafHeader')
        node.set('layer', 'opinions')

        lp_node = new_node('lp', node)

        lp_node.set('version', "#{last_edited}-#{version}")
        lp_node.set('name', description)

        if timestamp
          format = '%Y-%m-%dT%H:%M:%S%Z'

          lp_node.set('timestamp', Time.now.strftime(format))
        else
          lp_node.set('timestamp', '*')
        end
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

      ##
      # Get terms grouped by sentence.
      #
      def sentences
        @sentences ||= terms.group_by{|t| t.sentence}
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
        terms.each_with_index do |term, i|
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
        terms.each_with_index do |term, i|
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

      ##
      # Creates a new node in the KAF file.
      #
      def new_node(tag, parent)
        if parent.is_a?(String)
          parent_node = document.at_xpath(parent)
        else
          parent_node = parent
        end

        node = Oga::XML::Element.new(:name => tag)

        parent_node.children << node

        node
      end

      ##
      # Check if input is a KAF file.
      # @return [Boolean]
      #
      def is_kaf?
        !!document.at_xpath('KAF')
      end
    end # Processor
  end # OpinionDetectorBasic
end # Opener
