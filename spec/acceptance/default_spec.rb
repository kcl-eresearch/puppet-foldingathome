# Encoding: utf-8
require_relative '../../spec_linuxhelper'

describe 'foldingathome' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }
    end
  end
end
