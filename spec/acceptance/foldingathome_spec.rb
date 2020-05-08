require 'spec_helper_acceptance'

pp_basic = <<-PUPPETCODE
  class {'foldingathome':
    gpu_enable => false,
    user_name => 'fahpuppettestuser',
    user_passkey => '12345678901234567890123456789012',
    allow => '0/0',
    web_allow => '0/0',
    team_id => 0,
    cpu_slots => {
        '0' => '1',
        '1' => '1',
    },
  }
PUPPETCODE

idempotent_apply(pp_basic)

describe service('FAHClient') do
  it { is_expected.to be_enabled }
  it { is_expected.to be_running }
end
