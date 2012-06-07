# -*- coding: utf-8 -*-
$: << File.dirname(File.expand_path($PROGRAM_NAME)) + "/../lib"
require 'event_capture'
require 'optparse'

config = {}
OptionParser.new do |opt|
  opt.on('-p', '--print') {|boolean| config[:print] = boolean}
end

EventCapture.crawler(config)
