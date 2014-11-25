require 'opener/webservice'

module Opener
  class OpinionDetectorBasic
    ##
    # Basic opinion detector server powered by Sinatra.
    #
    class Server < Webservice::Server
      set :views, File.expand_path('../views', __FILE__)

      self.text_processor  = OpinionDetectorBasic
      self.accepted_params = [:input]
    end # Server
  end # OpinionDetectorBasic
end # Opener
