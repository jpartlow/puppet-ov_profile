# Return parameter defaults for the ov_profile::lb class.
#
# @param type The type of load balancer.
# @param parameter The parameter to retrieve defaults for.
function ov_profile::default_lb_params(
  Ov_profile::LbTypes $type,
  Enum[port,options,member_options] $parameter,
) {
  $common = {
    'options' => {
      'mode'    => 'tcp',
      'balance' => 'leastconn',
      'retries' => 3,
    },
  }
  $type_defaults = {
    'compiler' => {
      'port'    => 8140,
      'options' => {
        'option'  => [
          'tcplog',
          'redispatch',
          'httpchk GET /status/v1/simple',
        ],
        'http-check expect' => 'string running',
        'timeout' => [
          'connect 10s',
          'client 120s',
          'server 120s',
          'check 10s',
        ],
      },
      'member_options' => [
        [
          'check',
          'check-ssl',
          'verify required',
          'ca-file /etc/puppetlabs/puppet/ssl/certs/ca.pem',
          'inter 10s',
          'rise 2',
          'fall 3',
        ],
      ],
    },
    'ovdb' => {
      'port'    => 8081,
      'options' => {
        'option' => [
          'tcplog',
          'redispatch',
          # If we want to upgrade this to
          # 'httpchk GET /status/v1/simple',
          # then we need to generate a local concatenated cert/key pem
          # file for haproxy to use.
          'ssl-hello-chk',
        ],
        # If we were to hit the simple status endpoint...
        # 'http-check expect' => 'string running',
        'timeout' => [
          'connect 10s',
          'client 10m',
          'server 10m',
          'check 5s',
        ],
      },
      'member_options' => [
        'check inter 10s rise 2 fall 3',
      ],
    },
  }

  $defaults = $type_defaults[$type][$parameter]
  ($parameter == 'options') ? {
    true    => $common['options'] + $defaults,
    default => $defaults,
  }
}
