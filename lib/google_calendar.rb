# -*- coding: utf-8 -*-
require 'gcalapi'

module EventCapture
  class Calendar
    GOOGLE_CALENDAR_FEED = "http://www.google.com/calendar/feeds/%s/private/full"
    
    def initialize(mail, pass, is_print = false)
      @is_print = is_print
      feed = GOOGLE_CALENDAR_FEED % mail
      @calendar = GoogleCalendar::Calendar.new(
        GoogleCalendar::Service.new(mail, pass), feed
      )
    end
    
    def unregistered(list)
      title_queue = []
      list.each {|data| title_queue << data[:title]}
      # すでに登録済みのイベントならQueueにセットしない
      @calendar.events.each do |event|
        index = title_queue.index(event.title)
        unless index.nil?
          list.delete_at index
          title_queue.delete_at index
        end
      end
      list
    end
    
    def save(queue)
      queue.each do |e|
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
      true
    end
    
    def delete(list)
      title_queue = []
      list.each {|data| title_queue << data[:title]}
      @calendar.events do |event|
        index = title_queue.index(event.title)
        unless index.nil?
          event.destroy!
          puts "delete: #{e}" if @is_print
        end
      end
      true
    end
  end
end