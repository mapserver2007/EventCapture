# -*- coding: utf-8 -*-
require 'active_support'
require 'parallel_runner'
require 'yaml'

$: << File.dirname(__FILE__) + "/../lib"
require "modules/eroge"


ttt = EventCaptureModule::Eroge.new
ttt.crawle_to