# Configure openvox-server.
class ov_profile::server {
  contain 'puppet'
  $puppetdb_server = lookup(
    'openvoxdb::master::config::puppetdb_server',
    {
      default_value => undef,
    }
  )
  if $puppetdb_server =~ NotUndef {
    contain 'openvoxdb::master::config'
    Class['openvoxdb::master::puppetdb_conf'] ~> Class['puppet::server::service']
  }
}
