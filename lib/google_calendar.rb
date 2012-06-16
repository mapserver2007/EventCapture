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
      @cond = {
        "max-results" => 999,
        "orderby" => "starttime",
        "sortorder" => "descending"
      }
    end
    
    def unregistered(list)
      title_queue = []
      list.each {|data| title_queue << data[:title]}
      # すでに登録済みのイベントならQueueにセットしない
      @calendar.events(@cond).each do |event|
        index = title_queue.index(event.title)
        unless index.nil?
          title_queue.delete_at index
          list.delete_at index
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
      @calendar.events(@cond).each do |event|
        index = title_queue.index(event.title)
        unless index.nil?
          puts "delete: #{event.title}" if @is_print
          event.destroy!
        end
      end
      true
    end
    
    def delete_all
      @calendar.events(@cond).each do |event|
        puts "delete: #{event.title}"
        event.destroy!
      end
    end
  end
end