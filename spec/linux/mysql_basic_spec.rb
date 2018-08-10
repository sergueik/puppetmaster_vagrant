require 'spec_helper'

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

  context 'Indexes' do
    # origin: https://stackoverflow.com/questions/5213339/how-to-see-indexes-for-a-database-or-table
    query1=<<-EOF
      SELECT TABLE_NAME,
        COUNT(1) index_count,
        GROUP_CONCAT(DISTINCT(index_name) SEPARATOR ',\\n ') indexes
      FROM INFORMATION_SCHEMA.STATISTICS
      WHERE
        TABLE_SCHEMA = 'mysql'
        AND
        INDEX_NAME != 'primary'
      GROUP BY TABLE_NAME
      ORDER BY COUNT(1) DESC;
    EOF
    query1.gsub!(/$/, ' ')
    {
    # the example lists the expected indexes and tables together
    'mysql' =>
      %w|
          help_category
          name
          help_keyword
          name
        |,
    }.each do |db,database_or_index_columns|
      describe command(<<-EOF
        mysql -D '#{db}' -e "#{query1}"
      EOF
      ) do
        database_or_index_columns.each do |database_or_index_name|
          its(:stdout) { should contain database_or_index_name }
        end
      end
    end
    query2 =<<-EOF
      SELECT TABLE_NAME, TABLE_SCHEMA, INDEX_NAME from (
      SELECT DISTINCT s.* FROM INFORMATION_SCHEMA.STATISTICS s LEFT OUTER JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS t
      ON t.TABLE_SCHEMA = s.TABLE_SCHEMA
      AND t.TABLE_NAME = s.TABLE_NAME
      AND s.INDEX_NAME = t.CONSTRAINT_NAME
      WHERE 0 = 0
      AND t.CONSTRAINT_NAME IS NULL
      ) x;
    EOF
    query2.gsub!(/$/, ' ')
    {
    # the example lists the expected indexes and tables together
    'mysql' =>
      %w|
          tables_priv
          Grantor
          proxies_priv
          Grantor
        |,
    }.each do |db,database_or_index_columns|
      describe command(<<-EOF
        mysql -D '#{db}' -e "#{query2}" | tee '/tmp/query_result.txt'
      EOF
      ) do
        database_or_index_columns.each do |database_or_index_name|
          its(:stdout) { should contain database_or_index_name }
        end
      end
    end


    query2.gsub!(/$/, ' ')
    # In a real world scenario one get the following output
    #   TABLE_NAME TABLE_SCHEMA INDEX_NAME
    #   API        WSO2_API     API_ID
    #   API_SCOPES WSO2_API     API_ID
    #   API_SCOPES WSO2_API     SCOPE_ID
    #   ...
    # with the indexes often named same for different tables
    {
    'mysql' =>
      %w|
          TABLE_NAME TABLE_SCHEMA INDEX_NAME
          API        WSO2_API     API_ID
          API_SCOPES WSO2_API     API_ID
          API_SCOPES WSO2_API     SCOPE_ID
        |,
    }.each do |db,report_line|
      user = 'databse_user'
      password = 'database_user_password'
      describe command(<<-EOF
        mysql -u #{user} -p'#{password}' -D '#{db}' -e "#{query2}" | tee '/tmp/query_result.txt'
      EOF
      ) do
        database_or_index_columns.each do |database_or_index_name|
          its(:stdout) { should contain Regexp.new(report_line.strip.gsub!(/  +/, '\\s+'), Regexp::IGNORECASE) }
        end
      end
    end
  end

  # NOTE: this may fail on a vanilla db
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
