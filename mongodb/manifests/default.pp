include java
# TODO: puppet 3.8.1 compatilble version of java module
class {'mongodb::globals':
  manage_package_repo => true,
  manage_package      => true,
  service_provider    => 'systemd',
  before              => Class['mongodb::server','mongodb::client'],
}

class {'mongodb::server':
  auth             => true,
  replset          => 'rs',
    replset_config => {
      'rs' => {
        ensure  => present,
	members => ['mongo1:27017', 'mongo2:27017', 'mongo3:27017']
	# NOTE:
	# ==> mongo1: Warning: Can't connect to replicaset member mongo1:27017.
	# ==> mongo1: Warning: Can't connect to replicaset member mongo2:27017.
	# ==> mongo1: Warning: Can't connect to replicaset member mongo3:27017.
      }
    }
}

class {'mongodb::client':

}
# NOTE:
# ==> mongo2: Error: /Mongodb_user[User user on db testdb]:
# Only one of 'password_hash' or 'password' should be provided
mongodb::db { 'testdb':
  user          => 'user',
  # password => 'password',
  password_hash => 'c0f27fd328541800352c162c738ac2bd',
  require       => Class[mongodb::server]
}
