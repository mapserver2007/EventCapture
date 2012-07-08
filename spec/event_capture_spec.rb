# -*- coding: utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/../spec/event_capture_helper')

describe EventCapture, 'が実行する処理' do
  before do
    cal_auth = EventCapture.calendar_auth
    @mail = cal_auth["mail"]
    @pass = cal_auth["pass"]
    tw_auth = EventCapture.twitter_auth
    @user = tw_auth["send_to"]
  end
  
  let(:calendar) { EventCapture::Calendar.new(@mail, @pass) }
  let(:invalid_calendar) { EventCapture::Calendar.new("dummy", "dummy") }
  let(:twitter) { EventCapture::Tweet.new(EventCapture.twitter_auth) }
  
  it "カレンダー登録が成功すること" do
    list = EventCapture.calendar_test_data
    data = calendar.unregistered list
    calendar.save(data).should be_true
    calendar.delete(data)
  end
  
  it "メールアドレスまたはパスワードが間違っている場合、例外が発生すること" do
    data = EventCapture.calendar_test_data
    proc {
      invalid_calendar.save data
    }.should raise_error(GoogleCalendar::AuthenticationFailed)
  end
  
  it "各モジュールからデータを取得できること" do
    EventCapture.module_list.each do |m|
      list = EventCapture.load_module(m).constantize.send(:new).run
      list.should_not be_empty
      list.each do |data|
        data[:title].should_not be_nil
        data[:desc].should_not be_nil
        data[:where].should_not be_nil
        data[:date][0].should match(/^\d{4}$/)
        data[:date][1].should match(/^\d{1,2}$/)
        data[:date][2].should match(/^\d{1,2}$/)
      end
    end
  end
  
  it "Twitterに投稿できること" do
    twitter.post(Time.now.to_s) do |url|
      client = HTTPClient.new
      location_url = client.get(url).header.get("Location")[0][1]
      client.get(location_url).status.should == 200
    end
  end
  
  it "Twitterでダイレクトメッセージを送れること" do
    twitter.dm(@user, Time.now.to_s) do |text|
      text.should_not be_nil
    end
  end
end

