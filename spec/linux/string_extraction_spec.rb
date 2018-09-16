require 'spec_helper'
require 'pp'
require 'json'
require 'yaml'
require 'rexml/document'
include REXML

command_result = command('/bin/echo "answer: 42"').stdout
answer = begin
  $stderr.puts 'YAML test'
  $stderr.puts command_result
  @res = YAML.load(command_result)
  pp @res
  @res['answer']
rescue => e
  $stderr.puts e.to_s
  nil
end
pp answer

describe String(answer) do
  it { should eq '42' }
end

command_result = command('/bin/echo "{\\"answer\\":42}"').stdout
answer = begin
  @res = JSON.parse(command_result)
  @res['answer']
rescue => e
  $stderr.puts e.to_s
  nil
end
pp answer

describe String(answer) do
  it { should eq '42' }
end

command_result = command('/bin/echo "<?xml version=\\"1.0\\"?>\\n<project>\\n<answer value=\\"42\\"/>\\n</project>"').stdout
answer = begin
  @res = Document.new(command_result)
  pp @res
  @res.elements['project'].elements['answer'].attributes['value']
rescue => e
  $stderr.puts e.to_s
  nil
end
pp answer

describe String(answer) do
  it { should eq '42' }
end


command_result = command('/bin/echo "<?xml version=\\"1.0\\"?>\\n<project>\\n<answer value=\\"42\\"/>\\n</project>"').stdout
answer = begin
  @doc = Document.new(command_result)
  xpath = '/project/answer/@value'
  pp @doc
  @res = REXML::XPath.first(@doc, xpath).value
  $stderr.puts @res
  @res
rescue => e
  $stderr.puts e.to_s
  nil
end
pp answer

describe String(answer) do
  it { should eq '42' }
end

