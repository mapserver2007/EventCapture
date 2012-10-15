# -*- coding: utf-8 -*-
require 'active_support'
require 'parallel_runner'
require 'yaml'
require 'google_calendar'
require 'tweet'

module EventCapture
  VERSION = '0.0.3'
  
  class << self
    # モジュールのロード
    def load_module(plugin)
      require 'modules/' + plugin
      file = plugin.split("_").each_with_object("") {|m, str| str << m.capitalize}
      "EventCaptureModule::" + file
    end
    
    # モジュールの一覧を取得
    def module_list
      Dir::entries("lib/modules").each_with_object [] do |file, list|
        next if file == "." || file == ".."
        list << file.gsub(".rb", "")
      end
    end
    
    # 設定のロード
    def load_config(path)
      File.exists?(path) ? YAML.load_file(path) : ENV
    end
    
    # clockwork実行時間設定
    def clock
      path = File.dirname(__FILE__) + "/../config/clock.yml"
      load_config(path)
    end
    
    # カレンダーオブジェクト作成
    def calendar
      path = File.dirname(__FILE__) + "/../config/gcal.yml"
      auth = load_config(path)
      Calendar.new(auth["mail"], auth["pass"], @debug)
    end
    
    # Twitterオブジェクトを作成
    def twitter
      path = File.dirname(__FILE__) + "/../config/twitter.yml"
      auth = load_config(path)
      @user = auth["send_to"]
      Tweet.new(auth)
    end

    # Evernote認証情報
    def evernote_auth_token
      path = File.dirname(__FILE__) + "/../config/evernote.auth.yml"
      load_config(path)
    end
    
    # ツイート
    def tweet_to(list)
      @twitter = twitter
      list.each_parallel do |data|
        begin
          data[:date] = data[:date].join("/")
          tag = data[:tag]
          data.delete(:tag)
          data = data.values.reject{|e| e == ""}
          context = data.join(", ") + "\s#{tag}"
          @twitter.post(context) {|url| puts "twitter: #{url}" if @debug}
          @twitter.dm(@user, context) {|text| puts "DM: #{text}" if @debug}
        rescue Twitter::Error::Forbidden
          next
        end
      end
    end
    
    # クローラ
    def crawler(name)
      auth_token = evernote_auth_token['auth_token']
      MyLogger.auth_token = auth_token
      begin
        # データ取得
        list = load_module(name).constantize.send(:new).run do |data|
          puts "data: #{data[:title]}" if @debug
          MyLogger.info("#{name}: #{data[:title]}")
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
    
    def schedule_delete
      calendar.delete_all
    end
    
    # 起動する
    def run(config)
      @debug = config[:debug]
      c = clock
      module_list.each do |module_name|
        schedule = c[module_name] || c["default"]
        if schedule.instance_of? Array
          schedule.each {|s| yield module_name, s}
        else
          yield module_name, schedule
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