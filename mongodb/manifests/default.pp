include java
# TODO: puppet 3.8.1 compatilble version of java module
class {'mongodb::globals':
  manage_package_repo => true,
  manage_package      => true,
  service_provider    => 'systemd',
  before              => Class['mongodb::server','mongodb::client'],
}
$strip_domain_suffix = false
# Replica set
$port = '27017'
$cluser_members = ['mongo1.vagrant', 'mongo2:27017', 'mongo3:27017']
$relicaset_members = flatten($cluster_members.map |Integer $index, String $value| {
  $host = $value
  if $strip_domain_suffix {
    $res =  regsubst($host, '\..*$', '' , 'G')
  } else {
    $res = $host
  }
  $res
})

if $strip_domain_suffix {
  $mongodb_configure_node = regsubst($::hostname, '\..*$','','G')
} else { 
  $mongodb_configure_node = $::hostname
}
$replicaset_name  = 'rs'
$replicaset_members_expression = flatten($replicaset_members.map |Integer $index, String $value| {
  $host = $value
  if $index == 2 {
    $res = "{ _id: $index,  host: \"${host}:${port}\", arbiterOnly: true}"
  } else {
    $res = "{ _id: $index,  host: \"${host}:${port}\"}"
  }
  $res
}).join(',')

$cluster_peers = flatten(delete(delete($cluster_members, $::hostname), "${::hostname}.local.vagrant").join(' ')
# lists all members of the replica set, ignoring that arbiter never elevates to master
$mongodb_replicaset_members = $replicaset_members.join('|')

class {'mongodb::server':
  auth             => true,
  replset          => 'rs',
    replset_config => {
      'rs' => {
        ensure  => present,
	members => $members,
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
