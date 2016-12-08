require_relative '../windows_spec_helper'

context 'Run Java Application' do

  context 'With Class' do
    temp_path = 'C:\windows\temp'
    temp_path =  nil
    # java_path = 'D:\apps\java\jre1.8.0_112-64'
    java_path = 'C:\java\jdk1.8.0_101'
    class_code_base64 = 'yv66vgAAADQAHQoABgAPCQAQABEIABIKABMAFAcAFQcAFgEABjxpbml0PgEAAygpVgEABENvZGUBAA9MaW5lTnVtYmVyVGFibGUBAARtYWluAQAWKFtMamF2YS9sYW5nL1N0cmluZzspVgEAClNvdXJjZUZpbGUBAAhBcHAuamF2YQwABwAIBwAXDAAYABkBAARUZXN0BwAaDAAbABwBAANBcHABABBqYXZhL2xhbmcvT2JqZWN0AQAQamF2YS9sYW5nL1N5c3RlbQEAA2VycgEAFUxqYXZhL2lvL1ByaW50U3RyZWFtOwEAE2phdmEvaW8vUHJpbnRTdHJlYW0BAAdwcmludGxuAQAVKExqYXZhL2xhbmcvU3RyaW5nOylWACEABQAGAAAAAAACAAEABwAIAAEACQAAAB0AAQABAAAABSq3AAGxAAAAAQAKAAAABgABAAAAAwAJAAsADAABAAkAAAAlAAIAAQAAAAmyAAISA7YABLEAAAABAAoAAAAKAAIAAAAGAAgABwABAA0AAAACAA4='
    java_class_name = 'App'
    describe command(<<-EOF

      $java_path = '#{java_path}'
      $class_code_base64 = '#{class_code_base64}'
      $java_class_name = '#{java_class_name}'
      $bytes = [System.Convert]::FromBase64String($class_code_base64)
      $temp_path = '#{temp_path}'
      if ($temp_path -eq '') {
        $temp_path = $script_directory = [System.IO.Path]::GetDirectoryName(($MyInvocation.MyCommand.Definition -replace '\\', '\\\\'))
        # NOTE: Exception calling "GetDirectoryName" with "1" argument(s): "Illegal characters in path"
      }
      try {

        [IO.File]::WriteAllBytes([System.IO.Path]::Combine($temp_path, "${java_class_name}.class"),  $bytes )
        $env:PATH = "$env:PATH;${java_path}\\bin"
        pushd $temp_path
        dir "${java_class_name}.class"
        try {
          $command = "java ${java_class_name} 2>&1"
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
      its(:stdout) { should match /java output: Test/i }
      its(:stdout) { should match /#{java_class_name}.class/i }
    end
  end
  context 'With source' do
    temp_path = 'C:\windows\temp'
    # temp_path =  nil
    # java_path = 'D:\apps\java\jre1.8.0_112-64'
    java_path = 'C:\java\jdk1.8.0_101'
    java_class_name = 'App'
    java_class_source = <<-EOF
        import java.util.Properties;
        public class App {
          public static void main(String[] args) {
            System.err.println("Test");
            }
        }
    EOF
    describe command(<<-EOF    
      $java_path = '#{java_path}'
      $java_class_source = @'
      #{java_class_source}
'@
      $java_class_name = '#{java_class_name}'
      $temp_path = '#{temp_path}'
      $env:PATH = "$env:PATH;${java_path}\\bin"
      if ($temp_path -eq '') {
        $temp_path = $script_directory = [System.IO.Path]::GetDirectoryName(($MyInvocation.MyCommand.Definition -replace '\\', '\\\\'))
        # NOTE: Exception calling "GetDirectoryName" with "1" argument(s): "Illegal characters in path"
      }
      try {

      pushd $temp_path
         write-output $java_class_source| out-file -filepath "${java_class_name}.java" -encoding ASCII
        try {
          $command = "javac ${java_class_name}.java 2>&1"
          write-output ('Compiling Java class command: {0} in "{1}"' -f $command, $temp_path )
          $output = invoke-expression -command $command
          write-output ('java output: {0}' -f $output)
        } catch [Exception] {
          write-output (($_.Exception.Message) -split "`n")[0]
        }
        dir "${java_class_name}.class"
        try {
          $command = "java ${java_class_name} 2>&1"
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
      its(:stdout) { should match /java output: Test/i }
      its(:stdout) { should match /#{java_class_name}.class/i }
    end
  end

  # note there is also a `jrunscript` command in jdk
  # this is capable or interpreting a language-independent command-line script shells,
  # it is ranked experimental, and seldom used:
  # https://docs.oracle.com/javase/8/docs/technotes/tools/windows/jrunscript.html
  # http://www.herongyang.com/JavaScript/jrunscript-Run-JavaScript-Code-with-jrunscript.html
end 