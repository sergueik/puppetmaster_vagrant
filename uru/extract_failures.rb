#!/usr/bin/ruby

require 'rubygems'
require 'json'
require 'pp'

report_json = File.read('report_.json')
report_obj = JSON.parse(report_json)
report_obj['examples'].each do |example|
  if example['status'] !~ /passed/i
    pp [example['status'],example['full_description']]
  end
end
