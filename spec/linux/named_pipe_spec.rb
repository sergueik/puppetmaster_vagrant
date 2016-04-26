  context 'Pipes' do
    process = '/var/itlm/tlmagent.bin'
    named_pipe = '/var/itlm//clisock'
    process_mask = '[t]lmagent.bin'
    
    describe command("/bin/netstat -ano | grep '#{named_pipe}'") do
      its (:stdout) do
        should contain 'STREAM' 
        should contain 'LISTENING'
        should contain named_pipe
      end
    end
    
    describe command("/bin/netstat -anp | grep $(ps ax | grep '#{process_mask}' | awk '{print $1}')") do
      its (:stdout) do
        should contain 'STREAM'
        should contain 'LISTENING'
        should contain named_pipe
      end  
    end
    describe file(named_pipe)  do
      it { should be_socket } 
    end
  end
