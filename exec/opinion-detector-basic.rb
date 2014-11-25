#!/usr/bin/env ruby

require 'opener/daemons'

require_relative '../lib/opener/opinion_detector_basic'

daemon = Opener::Daemons::Daemon.new(Opener::OpinionDetectorBasic)

daemon.start
