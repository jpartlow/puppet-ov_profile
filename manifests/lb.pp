# Configure an haproxy load balancer.
#
# TODO: maxconn needs to be configurable, both for the listen, and
# member sides.
#
# @param members The nodes to balance across.
# @param type The type of nodes being balanced (affects defaults).
# @param port The service port.
# @param haproxy_options The options to supply for the listening
#   service on the haproxy.
# @param haproxy_member_options The options to supply for the members
#   being proxied to.
class ov_profile::lb (
  Hash[Stdlib::Fqdn, Stdlib::Ip::Address] $members = {},
  Ov_profile::LbTypes $type = 'compiler',
  Stdlib::Ip::Address $proxy_ip = $facts['networking']['ip'],
  Stdlib::Port $port =
    ov_profile::default_lb_params($type, 'port'),
  Variant[Hash,Array[Hash]] $haproxy_options =
    ov_profile::default_lb_params($type, 'options'),
  Variant[String,Array[Variant[String,Array]]] $haproxy_member_options =
    ov_profile::default_lb_params($type, 'member_options'),
) {
  include haproxy

  $listening_service = "${type}_cluster"
  haproxy::listen { $listening_service:
    collect_exported => false,
    ipaddress        => $proxy_ip,
    ports            => [$port],
    options          => $haproxy_options,
  }
  haproxy::balancermember { 'haproxy-members':
    listening_service => $listening_service,
    server_names      => $members.keys(),
    ipaddresses       => $members.values(),
    ports             => [$port],
    options           => $haproxy_member_options,
  }

  # XXX: This is an selinux escape hatch, because el images have
  # selinux enforcing and the haproxy context they ship cannot access
  # ports like 8140, 8081 by default, or
  # /etc/puppetlabs/puppet/ssl/certs/ca.pem,
  # or other socket/file permissions probably related to how the
  # puppetlabs-haproxy module sets up haproxy versus how the redhat
  # haproxy context expects the world to be.
  if $facts['os']['family'] == 'RedHat'
    and $facts['selinux'] == true
    and $facts['os']['selinux']['current_mode'] == 'enforcing'
  {
    class { 'selinux':
      mode   => 'permissive',
      before => Haproxy::Listen[$listening_service],
    }
  }
}
