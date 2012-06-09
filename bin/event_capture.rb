# -*- coding: utf-8 -*-
$: << File.dirname(File.expand_path($PROGRAM_NAME)) + "/../lib"
require 'event_capture'
require 'optparse'

config = {}
OptionParser.new do |opt|
  opt.on('-c', '--clock CLOCK') {|time| config[:clock_time] = time}
  opt.on('-p', '--print') {|boolean| config[:print] = boolean}
  opt.parse!
end

EventCapture.run(config)


#EventCapture.crawler(config)
