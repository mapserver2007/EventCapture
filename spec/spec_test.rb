# -*- coding: utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/../spec/event_capture_helper')

describe EventCapture, 'が実行する処理' do
  
  
  it "test" do
    EventCapture.load_module("toranoana_cd").constantize.send(:new).run
  end
  
end

