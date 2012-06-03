# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/google_calendar'
require File.dirname(__FILE__) + '/modules/runnet'

module EventCapture
  class Sample
    def call
      puts "job called"
      "job called"
    end
    
    def scrape
      obj = EventCapture::Module::Runnet.new
      list = obj.run
      require 'pp'
      pp list
    end
    
  end
end

sample = EventCapture::Sample.new
sample.scrape
#sample.calendar_delete
#sample.calendar_search("summer")

