# frozen_string_literal: true

require 'spec_helper'

describe 'ov_profile::postgres' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile.with_all_deps }

      context 'with multiple ovdb servers' do
        let(:params) do
          {
            'additional_ovdb_servers' => ['ovdb2.spec'],
          }
        end

        it 'generates additional ssl configuration' do
          is_expected.to(
            contain_openvoxdb__database__postgresql_ssl_rules('ovox: additional postgresql ssl rules for ovdb2.spec')
              .with(
                database_name:     'puppetdb',
                database_username: 'puppetdb',
                postgres_version:  '14',
              )
              .that_requires('Class[openvoxdb::database::postgresql]'),
          )
        end
      end
    end
  end
end
