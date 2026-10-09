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
  # Ensure that if Postgres initdb is going to be executed, it
  # does so *before* the ssl_configuration class lays down
  # private/public ssl keys within the datadir that initdb will be
  # initializing...otherwise initdb throws a hissy fit.
  #
  # This problem was cropping up on el systems. Debian based systems
  # weren't running into it because the server packages initialize the
  # cluster in a postinst step.
  #
  # TODO: That this isn't handled internally by puppet-openvoxdb
  # should be looked into more closely to see if I'm using the classes
  # wrong or if there's an ordering bug for el when
  # openvoxdb::server::postgresql_ssl_on is true.
  Class['postgresql::server::initdb'] ->
    Class['openvoxdb::database::ssl_configuration']

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
