# -*- coding: utf-8 -*-
require 'mechanize'
require 'parallel_runner'
require 'open-uri'

module EventCaptureModule
  class ToranoanaCd
    ROOT_URL = 'http://www.toranoana.jp'
    # とらのあな - CD今日のランキング
    URL = ROOT_URL + '/mailorder/mcd/ranking/daily.html'
    # 何位まで取得するか
    MAX_RANK_NUM = 1
    
    def initialize
      @result = []
      @nglist = nglist
    end
    
    def agent
      agent_obj = Mechanize.new
      agent_obj.read_timeout = 30
      cookie_str = "afg=0; domain=.toranoana.jp; path=/; expires=Session; size=4"
      uri = URI.parse(URL)
      Mechanize::Cookie.parse(uri, cookie_str) {|cookie|
        agent_obj.cookie_jar.add(uri, cookie)
      }
      agent_obj
    end
    
    # NGリストを取得
    def nglist
      path = File.dirname(__FILE__) + "/../../config/nglist.txt"
      ngwords = []
      File.open(path) do |f|
        f.each {|line| ngwords << line.strip}
      end
      ngwords
    end
    
    def run
      url_list.each_parallel {|url| crawle_to url}
      @result
    end
    
    def crawle_to(url)
      site = agent.get(url)
      info = (site/'td[class="DetailData_L"]')
      date = (site/'td[class="DetailData_R"]')[1].text
      data = {
        :title => info[0].text,
        :desc => info[1].text,
        :where => url,
        :date => date.split("/"),
        :tag => "#event_capture_toranoana_cd"
      }
      @result << data
    end
    
    # 音楽CDトップランキング順のURL一覧
    def url_list
      site = agent.get(URL)
      lines = (site/'table[class="RankPageStructure"]/tr/td[class="Block"]')
      detail_url_list = []
      lines.each_with_index do |line, i|
        elem = line.at("td[class='RankTblStructure_Td']/a")
        title = elem.at("br[3]").next.text.strip
        # NGリストに含まれるタイトルは除外
        if @nglist.part_include?(title).nil?
          detail_url_list << ROOT_URL + elem.attr("href")
          break if detail_url_list.length >= MAX_RANK_NUM
        end
      end
      detail_url_list
    end
  end
end

class Array
  def part_include?(s)
    self.each do |str|
      return true if s.scan(str).length > 0
    end
    nil
  end
end