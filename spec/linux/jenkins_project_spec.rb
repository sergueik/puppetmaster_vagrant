require 'spec_helper'
# use embedded XML class
# # alternarively use xmllint or xmlstarlet when installed
# https://www.xml.com/pub/a/2005/11/09/rexml-processing-xml-in-ruby.html
require 'rexml/document'
include REXML
require 'spec_helper'

# NOTE: malformed XML would abort the spec run altogether.
context 'Detect malformed XML Document in Jenkins' do
  jobs_dir = '/opt/jenkins/jobs'
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
        it { should match 'Able to load' }
      end
    end
  end
end
