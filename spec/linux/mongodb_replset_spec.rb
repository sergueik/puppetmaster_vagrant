require 'spec_helper'
context 'mongodb' do
  context 'Connecting to replica set' do
    rs_name = 'rs'
    # https://stackoverflow.com/questions/13912765/how-do-you-connect-to-a-replicaset-from-a-mongodb-shell
    rs_members = [
      'mongo-0',
      'mongo-1',
      'mongo-2'
    ]
    database = 'database'
    mongodb_port = '27017'
    user  ='user'
    password = 'password'
    nodes = rs_members.map do |mongodb_node|
      "#{mongodb_node}:#{mongodb_port}"
    end
    rs_connection_string = "mongodb://#{nodes}/#{database}?replicaSet=#{rs_name}"
    val = '42'
    describe command(<<-EOF
      echo 'db.collection.insertOne({ key : "#{val}" })' > /tmp/a.js
      echo 'print( db.inventory.find( { key: "#{val}" } ) )' >> /tmp/a.js
      mongo "#{rs_connection_string}" -u #{user} -p #{password} </tmp/a.js
    EOF
    ) do
      let(:path) { '/bin:/usr/bin:/sbin'}
      [
        'MongoDB server version: 3.4.2',
        "DBQuery: #{database}.inventory -> { \"key\" : \"#{val}\" }",
      ].each do |line|
        its(:stdout) { should match /#{line}/i }
      end
      its(:stderr) { should be_empty }
      its(:exit_status) {should eq 0 }
    end
  end
end
