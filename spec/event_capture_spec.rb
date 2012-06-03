# -*- coding: utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/../spec/event_capture_helper')

describe EventCapture, 'が実行する処理' do
  describe "サンプル" do
    before do
      @instance = EventCapture::Sample.new
    end
    it "とりあえずテストが成功すること" do
      @instance.call.should == "job called"
    end
  end
end

