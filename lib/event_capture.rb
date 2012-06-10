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
    
    # clockwork実行時間設定
    def clock
      path = File.dirname(__FILE__) + "/../config/clock.yml"
      YAML.load_file(path)
    end
    
    # カレンダーオブジェクト作成
    def calendar
      path = File.dirname(__FILE__) + "/../config/auth.yml"
      auth = YAML.load_file(path)
      EventCapture::Calendar.new(auth["mail"], auth["pass"], @debug)
    end
    
    # クローラ
    def crawler
      Runner.parallel(load_module) do |m|
        begin
          cal = calendar
          list = m.constantize.send(:new).run do |data|
            puts "data: #{data}" if @debug
          end
          list.each {|data| cal.add(data)}
          cal.save
        rescue => e
          puts e.message
        end
      end
    end
    
    # 起動する
    def run(config)
      @debug = config[:debug]
      yield clock
    end
  end
end

class String
  def constantize
    ActiveSupport::Inflector.constantize(self)
  end
end