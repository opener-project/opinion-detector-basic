module Opener
  class OpinionDetectorBasic
    class BaseProcessor

      attr_accessor :document, :timestamp, :opinion_strength, :pretty

      ##
      # @param [String|IO] file The KAF file/input to process.
      # @param [Hash] options. Options for timestamp and including strength to
      # opinions.
      # @param [TrueClass|FalseClass] pretty Enable pretty formatting, disabled
      #  by default due to the performance overhead.
      #
      def initialize file, options = {}
        @document = Nokogiri.XML file

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
        opinions.each.with_index do |opinion, index|
          add_opinion opinion, index+1
        end

        add_linguistic_processor

        if pretty then pretty_print(document) else document.to_xml end
      end

      def language
        @language ||= document.at_xpath('KAF').attr('xml:lang')
      end

      def terms
        @terms ||= document.xpath('KAF/terms/term').map do |term|
          Term.new(term, document, language)
        end
      end

      ##
      # Get terms grouped by sentence.
      #
      def sentences
        @sentences ||= terms.group_by{ |t| t.sentence }
      end

      ##
      # Creates a new node in the KAF file.
      #
      def new_node tag, parent
        if parent.is_a?(String)
          parent_node = document.at_xpath(parent)
        else
          parent_node = parent
        end

        node = Nokogiri::XML::Element.new(tag, document)

        parent_node.add_child node

        node
      end

      ##
      # Adds the entire opinion in the KAF file.
      #
      def add_opinion opinion, index
        opinion_node = new_node "opinion", "KAF/opinions"
        opinion_node['oid'] = "o#{index.to_s}"

        unless opinion.holders.empty?
          opinion_holder_node = new_node "opinion_holder", opinion_node
          add_opinion_element opinion_holder_node, opinion.holders
        end

        opinion_target_node = new_node "opinion_target", opinion_node

        unless opinion.target_ids.empty?
          add_opinion_element opinion_target_node, opinion.target_ids
        end

        expression_node = new_node "opinion_expression", opinion_node
        expression_node['polarity'] = opinion.polarity
        expression_node['strength'] = opinion.strength.to_s

        add_opinion_element expression_node, opinion.ids
      end

      ##
      # Remove the opinions layer from the KAF file if it exists and add a new
      # one.
      def add_opinions_layer
        existing = document.at_xpath('KAF/opinions')

        existing.remove if existing

        new_node 'opinions', 'KAF'
      end

      ##
      # Method for adding opinion holders, targets and expressions.
      #
      def add_opinion_element node, ids
        lemmas    = terms.select{|t| ids.include?(t.id)}.map(&:lemma).join(" ")
        comment   = Nokogiri::XML::Comment.new(document, "#{lemmas}")
        node.add_child comment

        span_node = new_node("span", node)

        ids.each do |id|
          target_node       = new_node("target", span_node)
          target_node['id'] = id.to_s
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
        node['layer'] = 'opinions'

        lp_node = new_node('lp', node)

        lp_node['version'] = "#{last_edited}-#{version}"
        lp_node['name'] = description

        if timestamp
          format = '%Y-%m-%dT%H:%M:%S%Z'

          lp_node['timestamp'] = Time.now.strftime(format)
        else
          lp_node['timestamp'] = '*'
        end
      end

      ##
      # Creates a new node in the KAF file.
      #
      def new_node tag, parent
        if parent.is_a?(String)
          parent_node = document.at_xpath(parent)
        else
          parent_node = parent
        end

        node = Nokogiri::XML::Element.new(tag, document)

        parent_node.add_child node

        node
      end

      ##
      # Check if input is a KAF file.
      # @return [Boolean]
      #
      def is_kaf?
        !!document.at_xpath('KAF')
      end

    end
  end
end
