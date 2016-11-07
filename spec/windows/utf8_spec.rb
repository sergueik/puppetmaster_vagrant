require_relative '../windows_spec_helper'

context 'UTF-8' do

file_path = 'C:\Users\vagrant\utf8.txt'
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
      iex "ruby.exe --% '#{script_file}'"
  # NOTE the quoting
    EOF
    ) do
      # using Puppet Community Edition
      if os[:arch] == 'i386'
        # 32bit environment
        let(:path) { 'C:/Program Files/Puppet Labs/Puppet/sys/ruby/bin' }
      else
        # 64-bt Puppet
        let(:path) { 'C:/Program Files (x86)/Puppet Labs/Puppet/sys/ruby/bin' }
      end
      its(:exit_status) { should eq 0 }
      its(:stderr) {  should be_empty }
    end
    describe file(file_path) do
      it { should be_file }
    end
  end

  context 'UTF-8 test' do
    # http://utf8checker.codeplex.com
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
              public bool Check(string fileName)
              {
                  using (BufferedStream fstream = new BufferedStream(File.OpenRead (fileName)))
                  {
                      return this.IsUtf8(fstream);
                  }
              }

              public bool IsUtf8(Stream stream)
              {
                  int count = 4 * 1024;
                  byte[] buffer;
                  int read;
                  while (true)
                  {
                      buffer = new byte[count];
                      stream.Seek(0, SeekOrigin.Begin);
                      read = stream.Read(buffer, 0, count);
                      if (read < count)
                      {
                          break;
                      }
                      buffer = null;
                      count *= 2;
                  }
                  return IsUtf8(buffer, read);
              }

              public static bool IsUtf8(byte[] buffer, int length)
              {
                  int position = 0;
                  int bytes = 0;
                  while (position < length)
                  {
                      if (!IsValid(buffer, position, length, ref bytes))
                      {
                          return false;
                      }
                      position += bytes;
                  }
                  return true;
              }

              public static bool IsValid(byte[] buffer, int position, int length, ref int  bytes)
              {
                  if (length > buffer.Length)
                  {
                      throw new ArgumentException("Invalid length");
                  }

                  if (position > length - 1)
                  {
                      bytes = 0;
                      return true;
                  }

                  byte ch = buffer[position];

                  if (ch <= 0x7F)
                  {
                      bytes = 1;
                      return true;
                  }

                  if (ch >= 0xc2 && ch <= 0xdf)
                  {
                      if (position >= length - 2)
                      {
                          bytes = 0;
                          return false;
                      }
                      if (buffer[position + 1] < 0x80 || buffer[position + 1] > 0xbf)
                      {
                          bytes = 0;
                          return false;
                      }
                      bytes = 2;
                      return true;
                  }

                  if (ch == 0xe0)
                  {
                      if (position >= length - 3)
                      {
                          bytes = 0;
                          return false;
                      }

                      if (buffer[position + 1] < 0xa0 || buffer[position + 1] > 0xbf ||
                          buffer[position + 2] < 0x80 || buffer[position + 2] > 0xbf)
                      {
                          bytes = 0;
                          return false;
                      }
                      bytes = 3;
                      return true;
                  }


                  if (ch >= 0xe1 && ch <= 0xef)
                  {
                      if (position >= length - 3)
                      {
                          bytes = 0;
                          return false;
                      }

                      if (buffer[position + 1] < 0x80 || buffer[position + 1] > 0xbf ||
                          buffer[position + 2] < 0x80 || buffer[position + 2] > 0xbf)
                      {
                          bytes = 0;
                          return false;
                      }

                      bytes = 3;
                      return true;
                  }

                  if (ch == 0xf0)
                  {
                      if (position >= length - 4)
                      {
                          bytes = 0;
                          return false;
                      }

                      if (buffer[position + 1] < 0x90 || buffer[position + 1] > 0xbf ||
                          buffer[position + 2] < 0x80 || buffer[position + 2] > 0xbf ||
                          buffer[position + 3] < 0x80 || buffer[position + 3] > 0xbf)
                      {
                          bytes = 0;
                          return false;
                      }

                      bytes = 4;
                      return true;
                  }

                  if (ch == 0xf4)
                  {
                      if (position >= length - 4)
                      {
                          bytes = 0;
                          return false;
                      }

                      if (buffer[position + 1] < 0x80 || buffer[position + 1] > 0x8f ||
                          buffer[position + 2] < 0x80 || buffer[position + 2] > 0xbf ||
                          buffer[position + 3] < 0x80 || buffer[position + 3] > 0xbf)
                      {
                          bytes = 0;
                          return false;
                      }

                      bytes = 4;
                      return true;
                  }

                  if (ch >= 0xf1 && ch <= 0xf3)
                  {
                      if (position >= length - 4)
                      {
                          bytes = 0;
                          return false;
                      }

                      if (buffer[position + 1] < 0x80 || buffer[position + 1] > 0xbf ||
                          buffer[position + 2] < 0x80 || buffer[position + 2] > 0xbf ||
                          buffer[position + 3] < 0x80 || buffer[position + 3] > 0xbf)
                      {
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