# -*- coding: utf-8 -*-
require 'log4r'
require 'log4r/evernote'

class MyLogger
  def self.method_missing(name, *args)
    if /(.*?)=$/ =~ name
      instance_variable_set("@#{$1}", args[0])
    else
      logger.send(name.to_s, args[0])
    end
  end
  
  def self.logger
    raise "auth token is empty." if @auth_token.nil?
    return @logger unless @logger.nil?
    @logger = Log4r::Logger.new(name)
    @logger.level = Log4r::INFO
    formatter = Log4r::PatternFormatter.new(
        :pattern => "[%l] %d %C: %M ",
        :date_format => "%Y/%m/%d %H:%M:%Sm"
    )
    stdoutOutputter = Log4r::StdoutOutputter.new('console', {
        :formatter => formatter
    })
    evernoteOutputter = Log4r::EvernoteOutputter.new(name, {
        :env => "production",
        :auth_token => @auth_token,
        :stack => "Log4ever",
        :notebook => "EventCapture",
        :tags => ['Log', 'EventCapture'],
        :shift_age => Log4ever::ShiftAge::MONTHLY,
        :formatter => formatter
    })
    @logger.outputters = [stdoutOutputter, evernoteOutputter]
    @logger
  end
end
