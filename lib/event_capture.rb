# -*- coding: utf-8 -*-
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
    
    # カレンダーオブジェクト作成
    def calendar
      path = File.dirname(__FILE__) + "/../config/auth.yml"
      auth = YAML.load_file(path)
      @calendar = EventCapture::Calendar.new(auth["mail"], auth["pass"], @is_print)
    end
    
    # クローラ
    def crawler
      Runner.parallel(load_module) do |m|
        begin
          list = m.constantize.send(:new).run() do |data|
            puts "data: #{data}" if @is_print
          end
          list.each do |data|
            @calendar.add(data)
          end
          @calendar.save
        rescue => e
          puts e.message
        end
      end
    end
    
    # 起動する
    def run(config)
      @is_print = config[:print]
      calendar
      yield config[:clock_time]
    end
  end
end

class String
  def constantize
    ActiveSupport::Inflector.constantize(self)
  end
end