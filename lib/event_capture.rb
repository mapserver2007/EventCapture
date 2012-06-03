# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/google_calendar'
require File.dirname(__FILE__) + '/modules/runnet'
require 'parallel_runner'
require 'yaml'

module EventCapture
  VERSION = '0.0.1'
  
  class << self
    include EventCaptureModule
    
    def auth
      path = File.dirname(__FILE__) + "/../config/auth.yml"
      YAML.load_file(path)
    end
    
    def crawler
      modules = [Runnet]
      path = File.dirname(__FILE__) + "/../config/auth.yml"
      auth = YAML.load_file(path)
      calendar = EventCapture::Calendar.new(auth["mail"], auth["pass"])
      
      Runner.parallel(modules) do |m|
        list = m.send(:new).run
        list.each do |data|
          calendar.add(data)
        end
        calendar.save
      end
      
    end
  end
end

EventCapture.crawler