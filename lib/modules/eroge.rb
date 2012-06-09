# -*- coding: utf-8 -*-
require 'mechanize'
require 'parallel_runner'

module EventCaptureModule
  class Eroge
    # ErogameScape−エロゲー批評空間− 発売日情報
    URL = "http://bit.ly/BIhjm"
    # 特典の閾値
    THRESHOLD = 300
    
    def run
      [{
        :title => "test",
        :desc => "test",
        :where => "test",
        :date => ["2012", "12", "31"]
        
      }]
    end
    
    def threshold(str)
      # 文字列を期待値と評価人数から合計得点を算出
      /(\d+)\((\d+)\)/ =~ str ? $1.to_i * $2.to_i : 0
    end
    
    def crawle_to
      agent = Mechanize.new
      agent.read_timeout = 30
      list = []
      site = agent.get(URL)
      lines = (site/'div[class="scape"]/table')
      p lines.length
      lines.each do |line|
        
        p line.parent.previous
        p "\n"
        
        line.search("tr").each do |td|
          
          expected_val = threshold(td.search("td[4]").text)
          next if expected_val > THRESHOLD
          
          # 発売日
          
          
          
          #title = td.search("td[1]").text
          #desc = td.search("td[2]").text
          
          #p title
          
          
        end
        
        
        
        
      end
      
      
      
    end
    
  end
  
  
  
end