# -*- coding: utf-8 -*-
$: << File.dirname(__FILE__) + "/../lib"
require 'event_capture'
require 'mylogger'
require 'optparse'
require 'clockwork'
include Clockwork

config = {}
OptionParser.new do |opt|
  opt.on('-d', '--debug') {|boolean| config[:debug] = boolean}
  opt.parse!
end

auth_token = EventCapture.evernote_auth_token['auth_token']
MyLogger.auth_token = auth_token

EventCapture.run(config) do |module_name, schedule|
  handler do |job| 
    # 短期間にジョブが実行される場合、待ちによりキューが溜まり続ける
    # ため、スレッドで並列実行する
    Thread.new {EventCapture.crawler job}
  end
  every(1.day, module_name, :at => schedule)
end
