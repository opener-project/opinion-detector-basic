#!/usr/bin/env ruby

require 'opener/daemons'

require_relative '../lib/opener/opinion_detector_basic'

Oga::XML::Parser.class_eval do
  include NewRelic::Agent::Instrumentation::ControllerInstrumentation
  include NewRelic::Agent::MethodTracer

  add_method_tracer(:parse)
end

Oga::XPath::Parser.class_eval do
  class << self
    include NewRelic::Agent::Instrumentation::ControllerInstrumentation
    include NewRelic::Agent::MethodTracer

    add_method_tracer(:parse_with_cache, 'Oga::XPath::Parser/parse_with_cache')
  end
end

Oga::XPath::Compiler.class_eval do
  include NewRelic::Agent::Instrumentation::ControllerInstrumentation
  include NewRelic::Agent::MethodTracer

  add_method_tracer(:compile)
end

Opener::OpinionDetectorBasic::Processor.class_eval do
  include NewRelic::Agent::Instrumentation::ControllerInstrumentation
  include NewRelic::Agent::MethodTracer

  add_method_tracer(:process)
  add_method_tracer(:terms)
  add_method_tracer(:opinions)
  add_method_tracer(:add_opinion_element)
  add_method_tracer(:pretty_print)
  add_method_tracer(:set_accumulated_strength)
  add_method_tracer(:apply_modifiers)
  add_method_tracer(:apply_conjunctions)
end

daemon = Opener::Daemons::Daemon.new(Opener::OpinionDetectorBasic)

daemon.start
