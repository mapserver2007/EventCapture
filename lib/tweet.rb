# -*- coding: utf-8 -*-
require 'twitter'

module EventCapture
  class Tweet
    TWITTER_URL = 'http://twitter.com'
    TWEET_URL = "#{TWITTER_URL}/statuses/update.json"
    TIMELINE_URL = "#{TWITTER_URL}/%s/status/%s"

    def initialize(params)
      auth(params)
      @client = Twitter::Client.new
      @user = params["send_to"]
    end

    def post(msg)
      msg = msg.to_s.force_encoding(Encoding::ASCII_8BIT)
      result = @client.update(msg)
      url = TIMELINE_URL % [result["user"]["name"], result["id"]]
      yield url if block_given?
    end
    
    def dm(user, msg)
      msg = msg.to_s.force_encoding(Encoding::ASCII_8BIT)
      result = @client.direct_message_create(user, msg)
      yield result["text"] if block_given?
    end

    def auth(params)
      Twitter.configure do |config|
        config.consumer_key = params["consumer_key"]
        config.consumer_secret = params["consumer_secret"]
        config.oauth_token = params["oauth_token"]
        config.oauth_token_secret = params["oauth_token_secret"]
      end
    end
  end
end