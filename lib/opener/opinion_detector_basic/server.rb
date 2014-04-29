require 'sinatra/base'
require 'httpclient'
require 'opener/webservice'

module Opener
  class OpinionDetectorBasic
    ##
    # Basic opinion detector server powered by Sinatra.
    #
    class Server < Webservice
      set :views, File.expand_path('../views', __FILE__)
      text_processor OpinionDetectorBasic
      accepted_params :input
    end # Server
  end # OpinionDetectorBasic
end # Opener
