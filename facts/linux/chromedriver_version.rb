# inspired by https://github.com/jantman/puppet-facter-facts/blob/master/virtualenv_version.rb
Facter.add("chromedriver_version") do
  setcode do
    begin
      /^ChromeDriver\s+(\d+\.\d+\.\d+)\s+.*$/.match(Facter::Util::Resolution.exec('chromedriver --version 2>&1')).captures.at(0)
    rescue
      false
    end
  end
end
