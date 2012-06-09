# -*- coding: utf-8 -*-
require 'clockwork'
require 'active_support'
require 'parallel_runner'
require 'yaml'
require 'google_calendar'

module EventCapture
  VERSION = '0.0.1'
  
  class << self
    # モジュールのロード
    def load_module
      Dir::entries("lib/modules").each_with_object [] do |file, list|
        next if file == "." || file == ".."
        file = File.basename(file, ".rb").split("_").each_with_object "" do |module_name, str|
          require 'modules/' + module_name
          str << module_name.capitalize
        end
        list << "EventCaptureModule::" + file
      end
    end
    
    # カレンダーオブジェクトを取得
    def calendar2
      path = File.dirname(__FILE__) + "/../config/auth.yml"
      auth = YAML.load_file(path)
      EventCapture::Calendar.new(auth["mail"], auth["pass"], @config[:print])
    end
    
    # クローラ
    def crawler()
      path = File.dirname(__FILE__) + "/../config/auth.yml"
      auth = YAML.load_file(path)
      calendar = EventCapture::Calendar.new(auth["mail"], auth["pass"], @config[:print])
      
      Runner.parallel(load_module) do |m|
        begin
          list = m.constantize.send(:new).run() do |data|
            puts "data: #{data}" if @config[:print]
          end
          list.each do |data|
            calendar.add(data)
          end
          calendar.save
        rescue => e
          puts e.message
        end
      end
    end
    
    def run(config)
      @config = config
      p config
      crawler
      #every(config[:clock_time].seconds, crawler)
    end
    
  end
end

class String
  def constantize
    ActiveSupport::Inflector.constantize(self)
  end
end