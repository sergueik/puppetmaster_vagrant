require 'spec_helper_acceptance'

describe 'example scenario' do
  context 'default' do
    it 'applies manifest without error' do
      pp = <<-EOS
        include example 
      EOS

      apply_manifest(pp, :catch_failures => true, :acceptable_exit_codes => [0, 2])

      # Novamente para verificar que não houve mudanças e nosso código é idempotente
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
    end


    describe package('httpd'), :if => os[:family] == 'RedHat' do
      it { should be_installed }
    end

    describe package('apache2'), :if => os[:family] == 'Debian' do
      it { should be_installed }
    end

    describe port(80) do
      it { should be_listening }
    end

  end
end
