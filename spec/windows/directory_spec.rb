# This is really a reusable code for rspec for Puppet erb processing
# where installer .inf contains a Dir=C:\\Program Files (x86)\\Application
it do
  should contain_File('c:/windows/temp/app.inf')
  .with_content(Regexp.new('C:\\Program Files (x86)\\Application'.gsub('\\','\\\\\\\\').gsub('(','\\\\(').gsub(')','\\\\)'), Regexp::IGNORECASE))
end
