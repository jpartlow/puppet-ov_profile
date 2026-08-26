# Configure an openvox agent.
class ov_profile::agent {
  class { 'puppet':
    server => false,
  }
}
