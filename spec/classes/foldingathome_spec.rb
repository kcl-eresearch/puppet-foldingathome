# frozen_string_literal: true

require 'spec_helper'

describe 'foldingathome' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }
      it { is_expected.to contain_package('fahclient').with_ensure('installed') }
      it {
        is_expected.to contain_File('/etc/fahclient').with(
          ensure: 'directory',
        )
      }
      it {
        is_expected.to contain_File('/etc/fahclient/config.xml').with(
          ensure: 'file',
          require: 'File[/etc/fahclient]',
          notify: 'Service[FAHClient]',
        )
      }
    end
  end
end
