require 'rspec'
require 'yaml'
require 'httpclient'
require File.dirname(__FILE__) + "/../lib/event_capture"
require File.dirname(__FILE__) + "/../lib/google_calendar"
require File.dirname(__FILE__) + "/../lib/tweet"

module EventCapture
  class << self
    def calendar_auth
      path = File.dirname(__FILE__) + "/../config/gcal.yml"
      YAML.load_file(path)
    end
    
    def twitter_auth
      path = File.dirname(__FILE__) + "/../config/twitter.yml"
      YAML.load_file(path)
    end
    
    def calendar_test_data
      [{
        :title => "test",
        :desc => "test",
        :where => "test",
        :date => ["2012", "12", "01"]
      }]
    end
  end
end