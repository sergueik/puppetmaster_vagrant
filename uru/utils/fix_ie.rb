require 'win32/registry'

# Suppress the internet Explorer dialog 'allow active content to run in files on my computer'
reg_key = 'Software\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_LOCALMACHINE_LOCKDOWN'
reg_value_name = 'iexplore.exe'

Win32::Registry::HKEY_CURRENT_USER.open(reg_key) do |reg|
  begin
    value = reg[reg_value_name, Win32::Registry::REG_DWORD]   
    p value # 0 
    reg.write(reg_value_name, Win32::Registry::REG_DWORD, '0')
  rescue => e
    puts e.to_s
    # Access is denied.
  end
end
