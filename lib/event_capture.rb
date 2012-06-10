# -*- coding: utf-8 -*-
require 'active_support'
require 'parallel_runner'
require 'yaml'
require 'google_calendar'
require 'tweet'

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
      Calendar.new(auth["mail"], auth["pass"], @debug)
    end
    
    # Twitterオブジェクトを作成
    def twitter
      path = File.dirname(__FILE__) + "/../config/twitter.yml"
      auth = YAML.load_file(path)
      Tweet.new(auth)
    end
    
    # ツイート
    def tweet_to(list)
      list.each do |data|
        begin
          data[:date] = data[:date].join("/")
          tag = data[:tag]
          data.delete(:tag)
          data = data.values.reject{|e| e == ""}
          context = data.join(", ") + "\s#{tag}"
          @twitter.post(context) do |url|
            puts "twitter: #{url}" if @debug
          end
        rescue Twitter::Error::Forbidden
          next
        end
      end
    end
    
    # クローラ
    def crawler
      @twitter = twitter
      Runner.parallel(load_module) do |m|
        begin
          # データ取得
          list = m.constantize.send(:new).run do |data|
            puts "data: #{data}" if @debug
          end
          # カレンダー登録
          cal = calendar
          data = cal.unregistered list
          cal.save data
          # Twitter投稿
          tweet_to data
        rescue => e
          puts e.message
        end
      end
    end
    
    # 起動する
    def run(config)
      @debug = config[:debug]
      crawler
      #yield clock
    end
  end
end

class String
  def constantize
    ActiveSupport::Inflector.constantize(self)
  end
end