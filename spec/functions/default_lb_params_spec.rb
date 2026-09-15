# frozen_string_literal: true

require 'spec_helper'

describe 'ov_profile::default_lb_params' do
  context 'compiler' do
    it 'gets the port' do
      is_expected.to run.with_params('compiler', 'port').and_return(8140)
    end

    it 'gets options' do
      defaults = call_function(
        'ov_profile::default_lb_params',
        'compiler',
        'options',
      )
      expect(defaults).to match(
        {
          'mode'              => 'tcp',
          'balance'           => 'leastconn',
          'retries'           => 3,
          'option'            => [
            'tcplog',
            'redispatch',
            'httpchk GET /status/v1/simple',
          ],
          'http-check expect' => 'string running',
          'timeout'           => [
            'connect 10s',
            'client 120s',
            'server 120s',
            'check 10s',
          ],
        },
      )
    end

    it 'gets member options' do
      is_expected.to(
        run.with_params('compiler', 'member_options').and_return(
          [
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
        ),
      )
    end
  end

  context 'ovdb' do
    it 'gets the port' do
      is_expected.to run.with_params('ovdb', 'port').and_return(8081)
    end

    it 'gets options' do
      defaults = call_function(
        'ov_profile::default_lb_params',
        'ovdb',
        'options',
      )
      expect(defaults).to match(
        {
          'mode'    => 'tcp',
          'balance' => 'leastconn',
          'retries' => 3,
          'option'  => %w[
            tcplog
            redispatch
            ssl-hello-chk
          ],
          'timeout' => [
            'connect 10s',
            'client 10m',
            'server 10m',
            'check 5s',
          ],
        },
      )
    end

    it 'gets member options' do
      is_expected.to(
        run.with_params('ovdb', 'member_options').and_return(
          [
            'check inter 10s rise 2 fall 3',
          ],
        ),
      )
    end
  end
end
