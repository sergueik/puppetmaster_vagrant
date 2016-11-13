require_relative '../windows_spec_helper'

# http://www.utf8-chartable.de/unicode-utf8-table.pl?start=1024
# http://utf8checker.codeplex.com
context 'UTF-8' do
  file_path = 'C:\Users\vagrant\utf8-test1.txt'
  context 'Setting up the environment' do
    script_file = 'c:/windows/temp/test.rb'
    ruby_script = <<-EOF
      File.open('#{file_path}', 'w') do |file|
        file.write(((1040..1071).to_a.pack('U*')) )
      end
    EOF
    describe command(<<-EOF
      @'
  #{ruby_script}
'@ | out-file '#{script_file}' -encoding ascii
      invoke-expression -command "ruby.exe --% '#{script_file}'"
      # NOTE the quoting
    EOF
    ) do
      # Using Ruby embedded in Puppet
      if os[:arch] == 'i386'
        # 32bit environment
        let(:path) { 'C:/Program Files/Puppet Labs/Puppet/sys/ruby/bin' }
      else
        # 64-bt Puppet - for older Puppet Community Edition releases
        let(:path) { 'C:/Program Files (x86)/Puppet Labs/Puppet/sys/ruby/bin' }
      end
      its(:exit_status) { should eq 0 }
      its(:stderr) {  should be_empty }
    end
    describe file(file_path) do
      # RSpec 3.x core (future ) syntax
      # https://www.relishapp.com/rspec/rspec-core/docs/subject/one-liner-syntax
      it { is_expected.to be_file }
      # equivalent RSpec 2 / obsolete (?) Serverspec matcher syntax
      it { should be_file }
    end
  end

  context 'Setting up the environment' do
    # NOTE: RSpec parameter is not scoped
    # NOTE: Relative paths do not work
    file2_path = 'c:/windows/temp/utf8-test2.txt'
    begin
      File.open(file2_path, 'w') do |file|
        file.write(((1040..1071).to_a.pack('U*')) )
      end
    rescue => e
      puts e.to_s
    end
    describe file(file2_path) do
      it { should exist }
      it { should be_file }
    end
  end

  context 'Detection of UTF-8 encoding' do
    describe command(<<-EOF
      add-type @'
using System;
using System.IO;

namespace Unicode
{
    public interface IUtf8Checker
    {
        // true if utf8 encoded, otherwise false.
        bool Check(string fileName);
        // true if utf8 encoded, otherwise false.
        bool IsUtf8(Stream stream);
    }
    public class Utf8Checker : IUtf8Checker
    {
        public bool Check(string fileName) {
            using (BufferedStream fstream = new BufferedStream(File.OpenRead(fileName))) {
                return this.IsUtf8(fstream);
            }
        }

        public bool IsUtf8(Stream stream) {
            int count = 4 * 1024;
            byte[] buffer;
            int read;
            while (true) {
                buffer = new byte[count];
                stream.Seek(0, SeekOrigin.Begin);
                read = stream.Read(buffer, 0, count);
                if (read < count) {
                    break;
                }
                buffer = null;
                count *= 2;
            }
            return IsUtf8(buffer, read);
        }

        public static bool IsUtf8(byte[] buffer, int length) {
            int position = 0;
            int bytes = 0;
            while (position < length) {
                if (!IsValid(buffer, position, length, ref bytes)) {
                    return false;
                }
                position += bytes;
            }
            return true;
        }

        public static bool IsValid(byte[] buffer, int position, int length, ref int bytes) {
            if (length > buffer.Length) {
                throw new ArgumentException("Invalid length");
            }
            if (position > length - 1) {
                bytes = 0;
                return true;
            }
            byte ch = buffer[position];
            if (ch <= 0x7F) {
                bytes = 1;
                return true;
            }
            if (ch >= 0xc2 && ch <= 0xdf) {
                if (position >= length - 2) {
                    bytes = 0;
                    return false;
                }
                if (buffer[position + 1] < 0x80 || buffer[position + 1] > 0xbf)  {
                    bytes = 0;
                    return false;
                }
                bytes = 2;
                return true;
            }
            if (ch == 0xe0) {
                if (position >= length - 3) {
                    bytes = 0;
                    return false;
                }
                if (buffer[position + 1] < 0xa0 || buffer[position + 1] > 0xbf ||
                    buffer[position + 2] < 0x80 || buffer[position + 2] > 0xbf)  {
                    bytes = 0;
                    return false;
                }
                bytes = 3;
                return true;
            }
            if (ch >= 0xe1 && ch <= 0xef) {
                if (position >= length - 3){
                    bytes = 0;
                    return false;
                }
                if (buffer[position + 1] < 0x80 || buffer[position + 1] > 0xbf ||
                    buffer[position + 2] < 0x80 || buffer[position + 2] > 0xbf)  {
                    bytes = 0;
                    return false;
                }
                bytes = 3;
                return true;
            }
            if (ch == 0xf0) {
                if (position >= length - 4) {
                    bytes = 0;
                    return false;
                }
                if (buffer[position + 1] < 0x90 || buffer[position + 1] > 0xbf ||
                    buffer[position + 2] < 0x80 || buffer[position + 2] > 0xbf ||
                    buffer[position + 3] < 0x80 || buffer[position + 3] > 0xbf){
                    bytes = 0;
                    return false;
                }
                bytes = 4;
                return true;
            }
            if (ch == 0xf4) {
                if (position >= length - 4) {
                    bytes = 0;
                    return false;
                }
                if (buffer[position + 1] < 0x80 || buffer[position + 1] > 0x8f ||
                    buffer[position + 2] < 0x80 || buffer[position + 2] > 0xbf ||
                    buffer[position + 3] < 0x80 || buffer[position + 3] > 0xbf) {
                    bytes = 0;
                    return false;
                }
                bytes = 4;
                return true;
            }
            if (ch >= 0xf1 && ch <= 0xf3) {
                if (position >= length - 4) {
                    bytes = 0;
                    return false;
                }
                if (buffer[position + 1] < 0x80 || buffer[position + 1] > 0xbf ||
                    buffer[position + 2] < 0x80 || buffer[position + 2] > 0xbf ||
                    buffer[position + 3] < 0x80 || buffer[position + 3] > 0xbf) {
                    bytes = 0;
                    return false;
                }
                bytes = 4;
                return true;
            }
            return false;
        }
    }
}
'@
      $o = new-object -typeName 'Unicode.Utf8Checker'
      $file_path = '#{file_path}'
      $o.Check($file_path)
    EOF
      ) do
        its(:exit_status) { should eq 0 }
        its(:stdout) { should contain 'False' }
    end
  end
end
