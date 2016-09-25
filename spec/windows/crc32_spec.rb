require_relative '../windows_spec_helper'

context 'crc32 check' do
  filepath = 'C:/Windows/system32/WindowsPowerShell/v1.0/powershell.exe'
  crc32hash = {
    '5.0.10586.117' => '0x50E803F3',
    '4.0' => '0x6AB6F097'
  }
  describe command(<<-EOF
    # returns  a crc32 of a file 

    # origin: http://poshcode.org/4946
    function ntdll_Crc32 {
      param([string]$FilePath)

      $_namespace = ("namespace_{0}" -f (([guid]::NewGuid()) -replace '-',''))
      $_name = 'ntdll_helper'
      $helper =  Add-Type -Namespace $_namespace -Name $_name -ErrorAction Stop -UsingNamespace @( 'System.IO') -PassThru  -MemberDefinition @"
[DllImport("ntdll.dll", CharSet = CharSet.Unicode)]
internal static extern UInt32 RtlComputeCrc32(
    UInt32 InitialCrc,
    Byte[] Buffer,
    Int32 Length
);

public static String computeCrc32(String filePath)
{
    UInt32 result = 0;
    Int32 dataSize;
    Byte[] buf = new Byte[4096];

    FileStream fs = File.OpenRead(filePath);
    while ((dataSize = fs.Read(buf, 0, buf.Length)) != 0)
        result = RtlComputeCrc32(result, buf, dataSize);
    fs.Close();

    return (String.Format("0x{0}",  result.ToString("X8")));
}
"@
      # $helper = New-Object -TypeName ('{0}.{1}' -f $_namespace,$_name)
      # Unable to cast object of type 'System.Management.Automation.PSObject' to type 'System.Type'.

      if (Test-Path -Path $FilePath) {
        try {
          [IO.File]::OpenRead($FilePath) | Out-Null
          $result = $helper::computeCrc32($FilePath)
        } catch [exception]{
        }
        write-output $result;
      }
    }
    $filePath = '#{filepath}'
    ntdll_Crc32 -FilePath $filePath
  EOF
  ) do
    its(:stdout) { should match crc32hash['4.0'] }
  end
end