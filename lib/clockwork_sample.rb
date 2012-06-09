# -*- coding: utf-8 -*-
require 'clockwork'
require File.dirname(__FILE__) + '/sample'

include Clockwork

handler do |job|
  job.call
end

every(10.seconds, EventCapture::Sample.new)