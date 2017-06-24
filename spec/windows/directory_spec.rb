# Reusable code for rspec for Puppet erb processing
# where installer .inf contains a Dir=C:\\Program Files (x86)\\Application

# the next example covers the minimal typical case for Windows path escaping
it do
  should contain_File('c:/windows/temp/app.inf')
  .with_content(Regexp.new('C:\\Program Files (x86)\\Application'.gsub('\\','\\\\\\\\').gsub('(','\\\\(').gsub(')','\\\\)'), Regexp::IGNORECASE))
end

# the next example covers the full special character coverage, e.g. for contents of RHEL systemd service launcher script generated from an erb
[
  'Dir=C:\\Program Files (x86)\\App'
].each do |line|
  {
  '\\' => '\\\\\\\\',
  '(' => '\\\\(',
  ')' => '\\\\)',
  ' ' => '\\s*',
  '+' => '\\\\+',
  '-' => '\\\\-',
  '*' => '\\\\*',  
  '?' => '\\\\?',  
  '{' => '\\\\{',
  '}' => '\\\\}',
  '[' => '\\\\[',
  ']' => '\\\\]',
  '$' => '\\\\$',
  }.each do |s,r|
    line.gsub!(s,r)
  end
  it do
    should contain_File('/usr/lib/systemd/system/httpd.service')
    .with_content(Regexp.new(line, Regexp::IGNORECASE))
  end

end
