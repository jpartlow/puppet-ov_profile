class ov_profile::postgres (
  Array[String[1]] $additional_ovdb_servers = [],
) {
  contain 'openvoxdb::database::postgresql'

  $database_name     = $openvoxdb::database::postgresql::database_name
  $database_username =
    $openvoxdb::database::postgresql::database_username
  $postgres_version  =
    $openvoxdb::database::postgresql::postgres_version

  $additional_ovdb_servers.each() |$ovdb| {
    openvoxdb::database::postgresql_ssl_rules { "ovox: additional postgresql ssl rules for ${ovdb}":
      database_name     => $database_name,
      database_username => $database_username,
      postgres_version  => $postgres_version,
      puppetdb_server   => $ovdb,
      require           => Class['openvoxdb::database::postgresql'],
    }
  }
}
