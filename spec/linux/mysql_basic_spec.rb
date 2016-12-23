context 'MySQL' do
  
  context 'DB'  do
    describe command(<<-EOF
      mysql -e 'SELECT DISTINCT DB FROM mysql.db;'
    EOF
    ) do
    [
      'test',
     # 'db name',
    ].each do |db|
        its(:stdout) { should contain(db) }
      end  
    end
  end
  
  context 'Databases' do
    {
    'test' => %w|
                  information_schema
                  test
                |,
    }.each do |db,databases|
      describe command(<<-EOF
        mysql -D '#{db}' -e 'show databases;'
      EOF
      ) do
        databases.each do |database_name|
          its(:stdout) { should contain database_name }
        end
      end
    end
  end

  context 'Users' do
    mysql_user = 'root'
    db = 'test'
    describe command(<<-EOF
      mysql -D '#{db}' -u #{mysql_user} -e 'SELECT User FROM mysql.user;'
    EOF
    ) do
      [
        'root@localhost',
      ].each do |user_name|
        its(:stdout) { should contain user_name.gsub(/@.+$/,'') }
      end
    end
  end

  context 'Grants' do
    {
      'privileged_user@%' => '*.*',
      'root@localhost'    => '*.*'
    }.each do |account,db|

      user, host, *rest  = account.split(/@/)
      describe command(<<-EOF
        mysql -e 'SHOW GRANTS FOR "#{user}"@"#{host}"'
      EOF
      ) do
        its(:exit_status) {should eq 0 }
        its(:stdout) { should match /GRANT ALL PRIVILEGES ON *.* TO '#{user}'@'#{host}'/i }
        its(:stderr) { should_not match /There is no such grant defined for user '#{user}' on host '#{host}'/i }
      end
    end
    user = 'none'
    host = 'localhost'
    describe command(<<-EOF
      mysql -e 'SHOW GRANTS FOR "#{user}"@"#{host}"'
    EOF
    ) do
        its(:stderr) { should match /There is no such grant defined for user '#{user}' on host '#{host}'/i }
    end
  end
end
