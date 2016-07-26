require 'spec_helper'

describe 'chef-3scale::default' do
  ###############
  # nginx service
  ###############

  describe service('nginx') do
    it { should be_enabled }
    it { should be_running }
  end

  describe command('/usr/sbin/nginx -V') do
    its(:stderr) { should contain('openresty') }
  end

  describe command('wget -qO - http://localhost:80') do
    its(:stdout) { should contain('Welcome to nginx!') }
  end

  ###########
  # log files
  ###########

  describe file('/var/log/nginx/error.log') do
    it { should be_file }
  end

  ##############
  # config files
  ##############

  describe file('/etc/nginx/nginx.conf') do
    it { should be_file }
    it { should be_symlink }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
  end

  describe file('/etc/nginx/nginx.sample.lua') do
    it { should be_file }
    it { should be_symlink }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
  end
end
