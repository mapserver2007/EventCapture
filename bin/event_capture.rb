# -*- coding: utf-8 -*-
$: << File.dirname(__FILE__) + "/../lib"
require 'event_capture'
require 'optparse'
require 'clockwork'
include Clockwork

config = {}
OptionParser.new do |opt|
  opt.on('-d', '--debug') {|boolean| config[:debug] = boolean}
  opt.parse!
end

EventCapture.run(config) do |clock|
  handler do |job| 
    # 短期間にジョブが実行される場合、待ちによりキューが溜まり続ける
    # ため、スレッドで並列実行する
    Thread.new {job.crawler}
  end
  unless clock["interval"].nil?
    every(clock["interval"].seconds, EventCapture)
  else
    every(1.day, EventCapture, :at => clock["schedule"])
  end
end
