# -*- coding: utf-8 -*-
require 'google_calendar'
require 'parallel_runner'
require 'yaml'
require 'active_support'

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
    
    # クローラ
    def crawler(config)
      path = File.dirname(__FILE__) + "/../config/auth.yml"
      auth = YAML.load_file(path)
      calendar = EventCapture::Calendar.new(auth["mail"], auth["pass"], config[:print])
      
      Runner.parallel(load_module) do |m|
        begin
          list = m.constantize.send(:new, config[:print]).run()
          list.each do |data|
            calendar.add(data)
          end
          calendar.save
        rescue => e
          puts e.message
        end
      end
    end
  end
end

class String
  def constantize
    ActiveSupport::Inflector.constantize(self)
  end
end