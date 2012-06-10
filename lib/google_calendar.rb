# -*- coding: utf-8 -*-
require 'gcalapi'

module EventCapture
  class SystemError < StandardError; end
  
  class Calendar
    GOOGLE_CALENDAR_FEED = "http://www.google.com/calendar/feeds/%s/private/full"
    
    def initialize(mail, pass, is_print = false)
      @is_print = is_print
      feed = GOOGLE_CALENDAR_FEED % mail
      @calendar = GoogleCalendar::Calendar.new(
        GoogleCalendar::Service.new(mail, pass), feed
      )
      clear
    end
    
    def add(data)
      @queue << data
      @title_queue << data[:title]
      self
    end
    
    def clear
      @queue = []
      @title_queue = []
    end
    
    def save
      # すでに登録済みのイベントならQueueから削除する
      @calendar.events.each do |event|
        index = @title_queue.index(event.title)
        unless index.nil?
          @queue.delete_at index
          @title_queue.delete_at index
        end
      end
      
      @queue.each do |e|
        event = @calendar.create_event
        event.title = e[:title]
        event.desc = e[:desc]
        event.where = e[:where]
        event.st = Time.mktime(*e[:date])
        event.en = event.st
        event.allday = true
        event.save!
        puts "save: #{e}" if @is_print
      end
      clear
      true
    end
    
    def delete
      @queue.each_with_index do |e, i|
        event = @calendar.events[i]
        raise SystemError if event == nil
        event.destroy!
        puts "delete: #{e}" if @is_print
      end
      clear
      true
    end
  end
end