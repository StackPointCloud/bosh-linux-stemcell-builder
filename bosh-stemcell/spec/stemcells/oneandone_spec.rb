require 'spec_helper'

describe 'Oneandone Stemcell', stemcell_image: true do
  it_behaves_like 'udf module is disabled'

  context 'rsyslog conf directory only contains files installed by rsyslog_config stage and cloud-init package' do
    describe command('ls -A /etc/rsyslog.d') do
      its (:stdout) { should eq(%q(21-cloudinit.conf
50-default.conf
avoid-startup-deadlock.conf
enable-kernel-logging.conf
))}
    end
  end

  context 'installed by system_parameters' do
    describe file('/var/vcap/bosh/etc/infrastructure') do
      its(:content) { should include('oneandone') }
    end
  end

  context 'installed by bosh_disable_password_authentication' do
    describe 'disallows password authentication' do
      subject { file('/etc/ssh/sshd_config') }

      its(:content) { should match /^PasswordAuthentication no$/ }
    end
  end
end
