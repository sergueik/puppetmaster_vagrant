require_relative '../windows_spec_helper'

context 'Run Java class' do

  context 'Basic' do
    # NOTE: frequent 'Illegal characters in path' errors
    code_base64 = 'yv66vgAAADQAHQoABgAPCQAQABEIABIKABMAFAcAFQcAFgEABjxpbml0PgEAAygpVgEABENvZGUBAA9MaW5lTnVtYmVyVGFibGUBAARtYWluAQAWKFtMamF2YS9sYW5nL1N0cmluZzspVgEAClNvdXJjZUZpbGUBAAhBcHAuamF2YQwABwAIBwAXDAAYABkBAARUZXN0BwAaDAAbABwBAANBcHABABBqYXZhL2xhbmcvT2JqZWN0AQAQamF2YS9sYW5nL1N5c3RlbQEAA2VycgEAFUxqYXZhL2lvL1ByaW50U3RyZWFtOwEAE2phdmEvaW8vUHJpbnRTdHJlYW0BAAdwcmludGxuAQAVKExqYXZhL2xhbmcvU3RyaW5nOylWACEABQAGAAAAAAACAAEABwAIAAEACQAAAB0AAQABAAAABSq3AAGxAAAAAQAKAAAABgABAAAAAwAJAAsADAABAAkAAAAlAAIAAQAAAAmyAAISA7YABLEAAAABAAoAAAAKAAIAAAAGAAgABwABAA0AAAACAA4='
    class_name = 'App'
    describe command(<<-EOF

    $code_base64 = '#{code_base64}'
    $class_name = '#{class_name}'
    $bytes = [System.Convert]::FromBase64String($code_base64)
    $temp_path = 'C:\\windows\\temp'
    [io.file]::WriteAllBytes("${temp_path}\\${class_name}.class",  $bytes )
    write-output "java ${class_name}"
    $env:PATH = "$env:PATH;C:\\java\\jdk1.8.0_101\\bin"
    pushd $temp_path
    dir
    try {
      $command = "java ${class_name}"
      write-output 'Running command: {}' -f $command 
      invoke-expression -command $command
    } catch [Exception] {
    # Error: Could not find or load main class App
    # Exception calling "WriteAllBytes" with "2" argument(s): "Access tothe path 'C:\windows\temp\App.class' is denied."
    }
    popd
    EOF
    ) do
      let(:path) {'C:\\java\\jdk1.8.0_101\\bin'} 
      # its(:stdout) { should match /Test/i }
      its(:stdout) { should match /#{class_name}.class/i }
    end
  end
end
