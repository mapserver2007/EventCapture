# -*- coding: utf-8 -*-
require 'mechanize'
require 'parallel_runner'

module EventCaptureModule
  class Runnet
    # runnet.jp
    URL = "http://runnet.jp"
    # エントリー開始大会情報
    NEW_ENTRY_URL = URL + "/runtes/newcomer.php?_page=%s"
    # 最大取得ページ数
    MAX_PAGE = 10
    
    def initialize
      @result = []
    end
    
    def run
      url_list = []
      1.upto(MAX_PAGE) {|page| url_list << NEW_ENTRY_URL % page }
      # 並列で取得
      url_list.each_parallel do |url|
        crawle_to url
      end
      @result.each {|data| yield data if block_given?}
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
          # タイトル
          title = line.search("td[3]").text
          # 詳細
          desc = ""
          line.search("td[3] > a").map {|a| desc = URL + a["href"]}
          data = {
            :title => "#{title}",
            :desc => desc,
            :where => where,
            :date => date,
            :tag => "#event_capture_runnet"
          }
          # リストにセット
          @result << data
        end
      end
    end
  end
end
