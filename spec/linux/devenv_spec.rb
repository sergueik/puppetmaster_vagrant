require 'spec_helper'
# based on: https://github.com/rejasupotaro/android-dev-env-serverspec 
config = Hash.new({})
config['file_cache_path']             = '/tmp'
config['setup_root']                  = '/Users/ken/local'
config['android-sdk']['name']         = 'android-sdk'
config['android-sdk']['version']      = '22.0.5'
config['android-sdk']['download_url'] = "http://dl.google.com/android/android-sdk_r#{config['android-sdk']['version']}-macosx.zip"
config['android-sdk']['components']   = %w(platform-tools
                                           build-tools-18.0.1
                                           android-18
                                           sysimg-18
                                           extra-android-support
                                           extra-google-google_play_services
                                           extra-google-m2repository
                                           extra-android-m2repository)

describe file(config['setup_root'] + config['android-sdk']['name']) do
  it {
    begin
      should be_directory
    rescue Exception => e
      puts "====== Installing android sdk..."

      download_url = config['android-sdk']['download_url']
      cache_file = config['file_cache_path'] + '/android-sdk-' + config['android-sdk']['version'] + '.zip'
      cmd = download(download_url, cache_file)
      expect(cmd.return_exit_status?(0)).to be_true

      extract_file = config['setup_root'] + '/android-sdk-' + config['android-sdk']['version']
      cmd = unzip(cache_file, extract_file)
      expect(cmd.return_exit_status?(0)).to be_true

      cmd = symlink(extract_file, config['setup_root'] + '/' + config['android-sdk']['name'])
      expect(cmd.return_exit_status?(0)).to be_true

      android_bin = config['setup_root'] + '/' + config['android-sdk']['name'] + '/android-sdk-macosx/tools/android'
      cmd = android_update(android_bin, config['android-sdk']['components'])
      expect(cmd.return_exit_status?(0)).to be_true
    end
  }
end

def download(url, output_path)
  puts "download #{url} to #{output_path}"
  create_cmd("curl #{url} -o #{output_path}")
end

def unzip(input_path, output_path)
  puts "extract #{input_path} to #{output_path}"
  create_cmd("unzip -o #{input_path} -d #{output_path}")
end

def symlink(from, to)
  puts "symlink #{from} to #{to}"
  create_cmd("ln -s #{from} #{to}")
end

def android_update(android_bin, components)
  puts "update #{components}"
  create_cmd("echo y | #{android_bin} update sdk --no-ui --filter #{components.join(',')} --force")
end

def create_cmd(command)
  Serverspec::Type::Command.new(command)
end