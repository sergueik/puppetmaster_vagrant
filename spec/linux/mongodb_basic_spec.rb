require 'spec_helper'

context 'mongodb' do
  context 'Admin User' do
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
  context 'Mongoimport' do
    database = 'test_database'
    test_database_data = <<-EOF
    [ 
      {
         "color": "black",
         "category": "hue",
         "type": "primary",
         "code": {
           "rgba": [255,255,255,1],
           "hex": "#000"
         }
       },
       {
         "color": "white",
         "category": "value",
         "code": {
           "rgba": [0,0,0,1],
           "hex": "#FFF"
         }
       },
       {
         "color": "red",
         "category": "hue",
         "type": "primary",
         "code": {
           "rgba": [255,0,0,1],
           "hex": "#FF0"
         }
       }
     
     ]
    EOF
    db_name = 'test'
    col_name = 'colors'
    datafile = '/tmp/test_database_data.json'
    describe command(<<-EOF
      echo '#{test_database_data}' > #{datafile}
      mongoimport --db #{db_name} --collection #{col_name} --jsonArray --file #{datafile}
    EOF
    ) do
      its(:stderr) { should match Regexp.new('connected to: *localhost') }
      its(:stderr) { should match /imported 3 documents/i }
      its(:stdout) { should be_empty }
      its(:exit_status) {should eq 0 }
    end
  end
end
