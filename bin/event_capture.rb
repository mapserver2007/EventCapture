# -*- coding: utf-8 -*-
$: << File.dirname(__FILE__) + "/../lib"
require 'event_capture'
require 'optparse'
require 'clockwork'
include Clockwork

config = {}
OptionParser.new do |opt|
  opt.on('-c', '--clock CLOCK') {|time| config[:clock_time] = time.to_i}
  opt.on('-p', '--print') {|boolean| config[:print] = boolean}
  opt.parse!
end

EventCapture.run(config) do |clock_time|
  handler do |job| 
    # 短期間にジョブが実行される場合、待ちによりキューが溜まり続ける
    # ため、スレッドで並列実行する
    Thread.new {job.crawler}
  end
  every(clock_time.seconds, EventCapture)
end
