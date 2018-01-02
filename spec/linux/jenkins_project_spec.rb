require 'spec_helper'
# use embedded XML  class
# https://www.xml.com/pub/a/2005/11/09/rexml-processing-xml-in-ruby.html
require 'rexml/document'
include REXML
require 'spec_helper'
context 'Jenkins' do
  jobs_dir = '/opt/jenkins/jobs'
  [
    'build1',
    'build2',
    'build3',
  ].each do |job|
    context "able to load #{job}" do
      file = File.new("#{jobs_dir}/#{job}/config.xml")
      doc = Document.new(file)
      puts doc.version
      it { should match 'able to load' }
    end
  end
end
