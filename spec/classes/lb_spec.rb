# frozen_string_literal: true

require 'spec_helper'

describe 'ov_profile::lb' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:members) do
        {
          'm1.spec' => '10.2.3.4',
          'm2.spec' => '10.2.3.5',
        }
      end
      let(:params) do
        {
          'members' => members,
        }
      end

      context 'compiler' do
        it { is_expected.to compile.with_all_deps }
      end

      context 'ovdb' do
        it do
          params['type'] = 'ovdb'
          is_expected.to compile.with_all_deps
        end
      end
    end
  end
end
