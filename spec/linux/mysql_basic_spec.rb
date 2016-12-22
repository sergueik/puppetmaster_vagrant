context 'MySQL' do
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
        its(:stdout) { should contain user_name.gsub('@localhost','') }
      end
    end
  end
end
