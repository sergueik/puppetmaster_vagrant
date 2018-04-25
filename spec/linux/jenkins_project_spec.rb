require 'spec_helper'

require_relative '../type/command'
require 'yaml'
require 'json'
require 'csv'
require 'pp'

# use embedded XML class
# # alternarively use xmllint or xmlstarlet when installed
# https://www.xml.com/pub/a/2005/11/09/rexml-processing-xml-in-ruby.html
require 'rexml/document'
include REXML

context 'Jenkins jobs' do
  jobs_dir = '/opt/jenkins/jobs'
  config_dir = '/vagrant'
  context 'Confirm able to load config.xml' do
    [
      'good.xml',
      'bad.xml'
    ].each do |config|
      xml = "#{config_dir}/#{config}"
      describe command( "cat #{xml}") do
        its(:stdout_as_xml) { should respond_to :version }
      end
    end
  end
  # NOTE: malformed XML would abort the spec run altogether.
  context 'Detect malformed XML Document in Jenkins' do
    [
      'build1',
      'build2',
      'build3',
    ].each do |job|
      context "Able to load #{job} config" do
        file_path = "#{jobs_dir}/#{job}/config.xml"
        if File.exists?(file_path)
          begin
            file = File.new(file_path)
          rescue => ex
            $stderr.puts ex.to_s
            # throw ex
          end
          doc = Document.new(file)
          puts doc.version
	  # better yet set subject 
          it { should match 'Able to load' }
        end
      end
    end
  end
end
