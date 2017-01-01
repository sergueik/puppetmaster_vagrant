require_relative '../windows_spec_helper'

require 'pp'
require 'jira-ruby'
require 'yaml'

# based on:
# https://github.com/jroucher/ServerSpec
# intend to merge with
# https://github.com/fnando/test_notifier

begin
  $config = YAML.load(File.open('spec/settings.yaml'))
rescue Exception => e
  puts "Could not parse YAML: #{e.message}"
  # Dir.entries('spec').each { |file| puts file }
end

class JiraRuby

  @client = nil

  def initialize
    options = {
      :username  => $config['username'],
      :password  => $config['password'],
      :site      => $config['server'],
      :ssl_verify_mode => OpenSSL::SSL::VERIFY_NONE,
      :context_path => '',
      :auth_type => :basic
    }
    @client = JIRA::Client.new(options)
  end

  def create(project, parentId, summary, description)
    issue2 = @client.Issue.build
    result = issue2.save({
      'fields' => {
        'parent' => {
          'id' => parentId.to_s
        },
        'summary' => summary,
        'description' =>  description,
        'project' => {
          'id' => project.to_s
        },
        'issuetype' => {
          'id' => '13'
        }
      }
    })
    if result
      puts "\nExecution "#{summary}" create successfully"
    else
      puts "\nExecution "#{summary}" produce error in creation"
    end
    issue2.fetch
  end
end

$execution = JiraRuby.new

describe 'Operating System', windows: true do
  before(:all){
    $errors = []
    $error_count = 0
  }
  after(:each) do |test|
    if test.exception != nil
      $error_count += 1
      $errors << "\n{panel:title=Error (#{$error_count}): } \n{code:java}\n{"
      $errors << test.exception.to_s
      $errors << "\n{code}\n{panel}"
    end
  end

  after(:all) {
    summary = if $error_count == 0
      'Success'
    else
      'Failure'
    end
    description = $errors.join("\n")
    puts 'Create issue in Jira: ' + summary + "\n" + description
    
    $execution.create($config['role'], $config['node'], summary, $errors.join("\n"))
  }

  describe host_inventory['platform'] do
    # dummy failing test
    it {distro.should match 'windows' }
  end

end

# depenencies
# jira-ruby-1.1.0.gem
# dependencies
# activesupport-4.2.7.1.gem
# 4.2.7.1 is the latestversion that does not require Ruby 2.2.2
# concurrent-ruby-1.0.4.gem
# i18n-0.7.0.gem
# minitest-5.10.1.gem
# oauth-0.5.1.gem
# thread_safe-0.3.5.gem
# tzinfo-1.2.2.gem