# -*- coding: utf-8 -*-
require 'gcalapi'

module EventCapture
  class SystemError < StandardError; end
  
  class Calendar
    GOOGLE_CALENDAR_FEED = "http://www.google.com/calendar/feeds/%s/private/full"
    
    def initialize(mail, pass)
      feed = GOOGLE_CALENDAR_FEED % mail
      @calendar = GoogleCalendar::Calendar.new(
        GoogleCalendar::Service.new(mail, pass), feed
      )
      clear
    end
    
    def add(data)
      @queue << data
      self
    end
    
    def clear
      @queue = []
    end
    
    def save
      @queue.each_with_index do |e, i|
        event = @calendar.events[i] || @calendar.create_event
        raise SystemError if event == nil
        event.title = e[:title]
        event.desc = e[:desc]
        event.where = e[:where]
        event.st = Time.mktime(*e[:date])
        event.en = event.st
        event.allday = true
        res = event.save!
        puts "save: #{e}"
      end
      clear
      true
    end
    
    def delete
      @queue.each_with_index do |e, i|
        event = @calendar.events[i]
        raise SystemError if event == nil
        event.destroy!
        puts "delete: #{e}"
      end
      clear
      true
    end
  end
end