require 'chefspec'
require 'spec_helper'
require 'timecop'

describe 'chef-3scale::default' do
  context 'local mode' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.set['network']['interfaces']['lo']['addresses'] = '127.0.0.1'
        node.set['kernel']['release'] = '2.6.32-504'
        node.set['3scale']['provider-key']  = 'THREESCALE_PROVIDER_KEY'
        node.set['3scale']['admin-domain']  = 'THREESCALE_ADMIN_DOMAIN'
        node.set['3scale']['config-source']  = 'local'
      end.converge(described_recipe)
    end

    before do
      Timecop.freeze(Time.new(2015, 9, 17, 12, 10, 10))
    end

    it 'installs required chef_gems' do
      expect(chef_run).to install_chef_gem('httpclient')
      expect(chef_run).to install_chef_gem('rubyzip')
    end

    it 'includes recipe openresty::ohai_plugin' do
      expect(chef_run).to include_recipe('openresty::ohai_plugin')
    end

    it 'includes recipe openresty::commons_user' do
      expect(chef_run).to include_recipe('openresty::commons_user')
    end

    it 'includes recipe openresty::commons_dir' do
      expect(chef_run).to include_recipe('openresty::commons_dir')
    end

    it 'includes recipe openresty::commons_script' do
      expect(chef_run).to include_recipe('openresty::commons_script')
    end

    it 'includes recipe openresty::commons_build' do
      expect(chef_run).to include_recipe('openresty::commons_build')
    end

    it 'includes recipe openresty::commons_cleanup' do
      expect(chef_run).to include_recipe('openresty::commons_cleanup')
    end

    it 'creates output directory' do
      expect(chef_run).to create_remote_directory('/var/chef/cache/2015-09-17-121010')
    end

    it 'runs ruby_block to symlink config files' do
      expect(chef_run).to run_ruby_block('symlink configuration files')
    end
  end
end

describe 'chef-3scale::default' do
  context '3scale mode' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.set['network']['interfaces']['lo']['addresses'] = '127.0.0.1'
        node.set['kernel']['release'] = '2.6.32-504'
        node.set['3scale']['provider-key']  = 'THREESCALE_PROVIDER_KEY'
        node.set['3scale']['admin-domain']  = 'THREESCALE_ADMIN_DOMAIN'
        node.set['3scale']['config-source']  = '3scale'
      end.converge(described_recipe)
    end

    it 'creates output directory' do
      expect(chef_run).to create_directory('/var/chef/cache/2015-09-17-121010')
    end

    it 'runs ruby_block to download files from 3scale' do
      expect(chef_run).to run_ruby_block('fetch configuration files from 3scale')
    end

    it 'runs ruby_block to symlink config files' do
      expect(chef_run).to run_ruby_block('symlink configuration files')
    end
  end
end

describe 'chef-3scale::default' do
  context 'rollback mode' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.set['network']['interfaces']['lo']['addresses'] = '127.0.0.1'
        node.set['kernel']['release'] = '2.6.32-504'
        node.set['3scale']['provider-key']  = 'THREESCALE_PROVIDER_KEY'
        node.set['3scale']['admin-domain']  = 'THREESCALE_ADMIN_DOMAIN'
        node.set['3scale']['config-source']  = '2010-10-10-101010'
      end.converge(described_recipe)
    end

    it 'should not create a new output directory' do
      expect(chef_run).to_not create_directory('/var/chef/cache/2010-10-10-101010')
    end

    it 'should not run a ruby_block to download files from 3scale' do
      expect(chef_run).to_not run_ruby_block('fetch configuration files from 3scale')
    end

    it 'runs a ruby_block to symlink config files' do
      expect(chef_run).to run_ruby_block('symlink configuration files')
    end
  end
end