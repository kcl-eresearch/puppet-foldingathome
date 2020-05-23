require 'spec_helper_acceptance'

pp_basic = <<-PUPPETCODE
  class {'foldingathome':
    gpu_enable     => false,
    user_name      => 'fahpuppettestuser',
    user_passkey   => '12345678901234567890123456789012',
    allow          => '0/0',
    web_allow      => '0/0',
    team_id        => 0,
    cpu_slots      => {
        '0' => '1',
        '1' => '1',
    },
    service_ensure => 'stopped'
  }
PUPPETCODE

idempotent_apply(pp_basic)
describe 'foldingathome' do
  describe service('FAHClient') do
    it { is_expected.to be_enabled }
    it { is_expected.not_to be_running }
  end

  describe file('/etc/fahclient/config.xml') do
    it { is_expected.to be_file }
    it { is_expected.to contain("<user v='fahpuppettestuser'/>") }
    it { is_expected.to contain("<passkey v='12345678901234567890123456789012' />") }
    it { is_expected.to contain("<team v='0'/>") }
    it { is_expected.to contain("<gpu v='false'/>") }
  end
end
