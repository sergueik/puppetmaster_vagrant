context 'Apache vhosts' do
  domain_suffix = '.puppet.localdomain'
  node_role = 'consul'
  filecount = 0
  path = '/etc/httpd/conf.d'
  path = '/tmp/files'
  # NOTE: cannot do string interpolation in the gsub that is inside. Also the expression is hard to read
  # filemask = path + '/' + "*-#{ENV['HOSTNAME'].gsub(domain_suffix,'')}.#{node_role}.conf"
  filemask = path + '/' + '*-' + %x( hostname -s ).chomp + '.' + node_role + '.conf'
  # puts "Globing : #{filemask}"
  # e.g. /etc/httpd/conf.d/54-node-rhel.consul.conf
  Dir.glob(filemask ).each do |filename|
    describe file(filename) do
      it  { should be_file }
    end
    filecount = filecount + 1
  end
   describe(filecount) do
    it { should_not be 0 }
   end
end
