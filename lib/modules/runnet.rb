# -*- coding: utf-8 -*-
require 'mechanize'
require 'parallel_runner'

module EventCaptureModule
  class Runnet
    # エントリー開始大会情報
    URL = "http://runnet.jp/runtes/newcomer.php?_page=%s"
    # 最大取得ページ数
    MAX_PAGE = 10
    
    def initialize
      @result = []
    end
    
    def run
      url_list = []
      1.upto(MAX_PAGE) {|page| url_list << URL % page }
      # 並列で取得
      Runner.parallel(url_list) do |url|
        crawle_to url
      end
      @result
    end
    
    def crawle_to(url)
      agent = Mechanize.new
      agent.read_timeout = 30
      list = []
      site = agent.get(url)
      lines = (site/'div[id="id01_m005"]/table/tr')
      lines.each do |line|
        # ランニングの場合のみ抽出
        if /\u30E9\u30F3\u30CB\u30F3\u30B0/ =~ line.search("td[4]").children[1].to_s
          # 日付
          date_str = line.search("td[1]").text
          date = []
          if /(\d{4}).*?(\d+).*?(\d+)/ =~ date_str
            date = [$1, $2, $3]
          end
          # 場所
          where = line.search("td[2]").text
          # タイトル、詳細
          race_name = desc = line.search("td[3]").text
          data = {
            :title => race_name,
            :desc => desc,
            :where => where,
            :date => date
          }
          puts "data: #{data}"
          # リストにセット
          @result << data
        end
      end
    end
  end
end
