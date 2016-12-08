require_relative '../windows_spec_helper'

context 'Run Java class' do

  context 'Basic' do
    temp_path = 'C:\windows\temp'
    # temp_path =  nil
    # java_path = 'D:\apps\java\jre1.8.0_112-64'
    java_path = 'C:\java\jdk1.8.0_101'
    code_base64 = 'yv66vgAAADQAHQoABgAPCQAQABEIABIKABMAFAcAFQcAFgEABjxpbml0PgEAAygpVgEABENvZGUBAA9MaW5lTnVtYmVyVGFibGUBAARtYWluAQAWKFtMamF2YS9sYW5nL1N0cmluZzspVgEAClNvdXJjZUZpbGUBAAhBcHAuamF2YQwABwAIBwAXDAAYABkBAARUZXN0BwAaDAAbABwBAANBcHABABBqYXZhL2xhbmcvT2JqZWN0AQAQamF2YS9sYW5nL1N5c3RlbQEAA2VycgEAFUxqYXZhL2lvL1ByaW50U3RyZWFtOwEAE2phdmEvaW8vUHJpbnRTdHJlYW0BAAdwcmludGxuAQAVKExqYXZhL2xhbmcvU3RyaW5nOylWACEABQAGAAAAAAACAAEABwAIAAEACQAAAB0AAQABAAAABSq3AAGxAAAAAQAKAAAABgABAAAAAwAJAAsADAABAAkAAAAlAAIAAQAAAAmyAAISA7YABLEAAAABAAoAAAAKAAIAAAAGAAgABwABAA0AAAACAA4='
    class_name = 'App'
    describe command(<<-EOF

      <#
        import java.util.Properties;
        public class App {
          public static void main(String[] args) {
            System.err.println("Test");
            }
        }
      #>

      $java_path = '#{java_path}'
      $code_base64 = '#{code_base64}'
      $class_name = '#{class_name}'
      $bytes = [System.Convert]::FromBase64String($code_base64)
      $temp_path = '#{temp_path}'
      if ($temp_path -eq '') {
        $temp_path = $script_directory = [System.IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Definition)
        # NOTE: Exception calling "GetDirectoryName" with "1" argument(s): "Illegal characters in path"
      }
      try {

        [IO.File]::WriteAllBytes([System.IO.Path]::Combine($temp_path, "${class_name}.class"),  $bytes )
        $env:PATH = "$env:PATH;${java_path}\\bin"
        pushd $temp_path
        dir "${class_name}.class"
        try {
          $command = "java ${class_name} 2>&1"
          write-output ('Running command: {0} in "{1}"' -f $command, $temp_path )
          $output = invoke-expression -command $command
          write-output ('java output: {0}' -f $output)
        } catch [Exception] {
          write-output (($_.Exception.Message) -split "`n")[0]
        }
      } catch [Exception] {
          write-output (($_.Exception.Message) -split "`n")[0]
      }
      popd
    EOF
    ) do
      let(:path) { "#{java_path}\\bin" }
      its(:stdout) { should match /java output: Test123/i }
      its(:stdout) { should match /#{class_name}.class/i }
    end
  end

  # note there is also a `jrunscript` command in jdk
  # this is capable or interpreting a language-independent command-line script shells,
  # it is ranked experimental, and seldom used:
  # https://docs.oracle.com/javase/8/docs/technotes/tools/windows/jrunscript.html
  # http://www.herongyang.com/JavaScript/jrunscript-Run-JavaScript-Code-with-jrunscript.html

end