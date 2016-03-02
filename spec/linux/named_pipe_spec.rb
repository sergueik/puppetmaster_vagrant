  context 'Pipes' do
    process = '/var/itlm/tlmagent.bin'
    named_pipe = '/var/itlm//clisock'
    process_mask = '[t]lmagent.bin'
    
    describe command("/bin/netstat -ano | grep '#{named_pipe}'") do
      its (:stdout) { should contain 'STREAM' }
      its (:stdout) { should contain 'LISTENING' }
      its (:stdout) { should contain named_pipe }
    end
    
    describe command("/bin/netstat -anp | grep $(ps ax | grep '#{process_mask}' | awk '{print $1}')") do
      its (:stdout) { should contain 'STREAM' }
      its (:stdout) { should contain 'LISTENING' }
      its (:stdout) { should contain named_pipe }
    end
    describe file(named_pipe)  do
      it { should be_socket } 
    end
  end
