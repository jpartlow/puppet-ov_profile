# Install and configure PostgreSQL for openvoxdb.
#
# @param max_connections Maximum number of connections the Postgresql
#   instance will accept.
# @param additional_ovdb_servers An array of additional openvoxdb
#   servers that need cert authorization for https access to the
#   PostgreSQL server.
class ov_profile::postgres (
  Integer $max_connections = 200,
  Array[String[1]] $additional_ovdb_servers = [],
) {
  if ($facts['os']['family'] == 'RedHat' and
      ($facts['os']['release']['major'] in ['8','9'])) {
    package { 'disable-builtin-dnf-postgresql-module':
      ensure   => 'disabled',
      name     => 'postgresql',
      provider => 'dnfmodule',
    }
  }

  contain 'openvoxdb::database::postgresql'

  postgresql::server::config_entry { 'max_connections':
    ensure => 'present',
    value  => $max_connections,
    # the define manages its requires
  }

  $database_name     = $openvoxdb::database::postgresql::database_name
  $database_username =
    $openvoxdb::database::postgresql::database_username
  $read_database_username =
    $openvoxdb::database::postgresql::read_database_username
  $rw_identity_map_key = "${database_name}-${database_username}-map"
  $ro_identity_map_key =
    "${database_name}-${read_database_username}-map"

  $additional_ovdb_servers.each() |$ovdb| {
    postgresql::server::pg_ident_rule { "ovox: mapping of ${ovdb} cert as a ${database_username} user":
      map_name          => $rw_identity_map_key,
      system_username   => $ovdb,
      database_username => $database_username,
      require           => Class['openvoxdb::database::postgresql'],
    }

    postgresql::server::pg_ident_rule { "ovox: mapping of ${ovdb} cert as a ${read_database_username} user":
      map_name          => $ro_identity_map_key,
      system_username   => $ovdb,
      database_username => $read_database_username,
      require           => Class['openvoxdb::database::postgresql'],
    }
  }
}
