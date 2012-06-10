# -*- coding: utf-8 -*-
require 'mechanize'
require 'parallel_runner'

module EventCaptureModule
  class Eroge
    # ErogameScape−エロゲー批評空間− 発売日情報
    URL = "http://bit.ly/BIhjm"
    # 特典の閾値
    THRESHOLD = 1000
    
    def initialize
      @result = []
    end
    
    def run
      crawle_to URL
      @result.each {|data| yield data if block_given?}
      @result
    end
    
    def threshold(str)
      # 文字列を期待値と評価人数から合計得点を算出
      /(\d+)\((\d+)\)/ =~ str ? $1.to_i * $2.to_i : 0
    end
    
    def crawle_to(url)
      agent = Mechanize.new
      agent.read_timeout = 30
      list = []
      site = agent.get(url)
      lines = (site/'div[class="scape"]/table')
      lines.each do |line|
        date = []
        date_str = line.previous.previous.search("a[2]").text
        if /(\d{4}).*?(\d+).*?(\d+)/ =~ date_str
          date = [$1, $2, $3]
        end
        line.search("tr").each do |td|
          title = td.search("td[1]").text
          desc = td.search("td[2]").text
          expected_val = threshold(td.search("td[4]").text)
          next if THRESHOLD > expected_val || title == "" || desc == ""
          data = {
            :title => "#{title}",
            :desc => "メーカ: #{desc} 得点: #{expected_val}",
            :where => "",
            :date => date,
            :tag => "#event_capture_eroge"
          }
          # リストにセット
          @result << data
        end
      end
    end
  end
end