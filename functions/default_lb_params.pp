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
    }
  }
  $type_defaults = {
    'compiler' => {
      'port'    => 8140,
      'options' => {
        'option'  => [
          'tcplog',
          'redispatch',
        ],
        'timeout' => [
          'connect 10s',
          'client 120s',
          'server 120s',
        ],
      },
      'member_options' => [
        'check inter 30s rise 2 fall 3',
      ],
    },
    'ovdb' => {
      'port'    => 8081,
      'options' => {
        'option' => [
          'tcplog',
          'redispatch',
          'httpchk GET /status/v1/simple',
        ],
        'http-check expect' => 'string running',
        'timeout' => [
          'connect 10s',
          'client 10m',
          'server 10m',
        ],
      },
      'member_options' => [
        'check port 8080 inter 30s rise 2 fall 3',
      ],
    },
  }

  $defaults = $type_defaults[$type][$parameter]
  ($parameter == 'options') ? {
    true    => $common['options'] + $defaults,
    default => $defaults,
  }
}
