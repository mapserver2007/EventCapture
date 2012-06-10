require 'rspec'
require 'yaml'
require File.dirname(__FILE__) + "/../lib/event_capture"
require File.dirname(__FILE__) + "/../lib/google_calendar"

module EventCapture
  class << self
    def auth
      path = File.dirname(__FILE__) + "/../config/auth.yml"
      YAML.load_file(path)
    end
    
    def calendar_test_data
      {
        :title => "test",
        :desc => "test",
        :where => "test",
        :date => ["2012", "12", "01"]
      }
    end
  end
end