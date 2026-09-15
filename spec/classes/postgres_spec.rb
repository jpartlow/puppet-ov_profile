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
            contain_postgresql__server__pg_ident_rule(
              'ovox: mapping of ovdb2.spec cert as a puppetdb user',
            )
              .with(
                map_name: 'puppetdb-puppetdb-map',
                system_username: 'ovdb2.spec',
                database_username: 'puppetdb',
              )
              .with_require('Class[Openvoxdb::Database::Postgresql]'),
          )
          is_expected.to(
            contain_postgresql__server__pg_ident_rule(
              'ovox: mapping of ovdb2.spec cert as a puppetdb-read user',
            )
              .with(
                map_name: 'puppetdb-puppetdb-read-map',
                system_username: 'ovdb2.spec',
                database_username: 'puppetdb-read',
              )
              .with_require('Class[Openvoxdb::Database::Postgresql]'),
          )
        end
      end
    end
  end
end
