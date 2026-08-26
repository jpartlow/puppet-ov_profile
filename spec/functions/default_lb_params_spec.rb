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
          'mode'    => 'tcp',
          'balance' => 'leastconn',
          'retries' => 3,
          'option'  => %w[
            tcplog
            redispatch
          ],
          'timeout' => [
            'connect 10s',
            'client 120s',
            'server 120s',
          ],
        },
      )
    end

    it 'gets member options' do
      is_expected.to(
        run.with_params('compiler', 'member_options').and_return(
          [
            'check inter 30s rise 2 fall 3',
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
          'mode'              => 'tcp',
          'balance'           => 'leastconn',
          'http-check expect' => 'string running',
          'retries'           => 3,
          'option'            => [
            'tcplog',
            'redispatch',
            'httpchk GET /status/v1/simple',
          ],
          'timeout'           => [
            'connect 10s',
            'client 10m',
            'server 10m',
          ],
        },
      )
    end

    it 'gets member options' do
      is_expected.to(
        run.with_params('ovdb', 'member_options').and_return(
          [
            'check port 8080 inter 30s rise 2 fall 3',
          ],
        ),
      )
    end
  end
end
