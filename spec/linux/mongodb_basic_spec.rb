require 'spec_helper'

context 'mongodb' do
  context 'Admin' do
    database = 'database'
    mongodb_port = '27017'
    user  ='user'
    password = 'password'
    describe command(<<-EOF
      echo 'use admin' > /tmp/a.txt
      echo 'print(db.system.users.findOne({user: "AdminUser"}))' >> /tmp/a.txt
      echo 'exit' >> /tmp/a.txt
      mongo -u #{user} -p #{password} </tmp/a.txt
    EOF
    ) do
      its(:stdout) { should match 'admin' }
      its(:stderr) { should be_empty }
      its(:exit_status) {should eq 0 }
    end
  end
end