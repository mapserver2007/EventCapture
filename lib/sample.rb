# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/google_calendar'

module EventCapture
  class Sample
    def call
      puts "job called"
      "job called"
    end
    
    def calendar_add
      calendar = EventCapture::Calendar.new
      calendar.add({
        :title => "てすと",
        :desc => "かれんだーてすと",
        :where => "東京ビッグサイト",
        :date => [2012, 6, 6]
      }).save
    end
    
    def calendar_delete()
      calendar = EventCapture::Calendar.new
      calendar.add({
        :title => "てすと",
        :desc => "かれんだーてすと",
        :where => "東京ビッグサイト",
        :date => [2012, 6, 6]
      }).delete
      
      
    end
    
  end
end

sample = EventCapture::Sample.new
sample.calendar_add
#sample.calendar_delete
#sample.calendar_search("summer")

