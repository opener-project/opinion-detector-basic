require 'nokogiri'

module Opener
  class OpinionDetectorBasic
    ##
    # Add Error Layer to KAF file instead of throwing an error.
    #
    class ErrorLayer
      attr_accessor :input, :document, :error, :klass
      
      def initialize(input, error, klass)
        @input    = input.to_s
        # Make sure there is always a document, even if it is empty.
        @document = Nokogiri::XML(input) rescue Nokogiri::XML(nil)
        @error    = error
        @klass    = klass
      end
      
      def add
        if is_xml?
          unless has_errors_layer?
            add_errors_layer
          end
        else
          add_root
          add_text
          add_errors_layer
        end
        add_error
        
        xml = !!document.encoding ? document.to_xml : document.to_xml(:encoding => "UTF-8")
        
        return xml
      end
      
      ##
      # Check if the document is a valid XML file.
      #
      def is_xml?
        !!document.root
      end
      
      ##
      # Add root element to the XML file.
      #
      def add_root
        root = Nokogiri::XML::Node.new "KAF", document
        document.add_child(root)
      end
      
      ##
      # Check if the document already has an errors layer.
      #
      def has_errors_layer?
        !!document.at('errors')
      end
      
      ##
      # Add errors element to the XML file.
      #
      def add_errors_layer
        node = Nokogiri::XML::Node.new "errors", document
        document.root.add_child(node)
      end
      
      ##
      # Add the text file incase it is not a valid XML document. More
      # info for debugging.
      #
      def add_text
        node = Nokogiri::XML::Node.new "raw", document
        node.inner_html = input
        document.root.add_child(node)
        
      end
      
      ##
      # Add the actual error to the errors layer.
      #
      def add_error
        node = document.at('errors')
        error_node = Nokogiri::XML::Node.new "error", node
        error_node['class']   = klass.to_s
        error_node['version'] = klass::VERSION
        error_node.inner_html = error
        node.add_child(error_node)
      end     
      
    end # ErrorLayer
  end # OpinionDetectorBasic
end # Opener
