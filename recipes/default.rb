#
# Cookbook Name:: chef-3scale
# Recipe:: default
#
# Copyright (C) 2015 3scale Inc. (https://3scale.net)
#
# All rights reserved - Do Not Redistribute
#

include_recipe 'openresty::ohai_plugin'
include_recipe 'openresty::commons_user'
include_recipe 'openresty::commons_dir'
include_recipe 'openresty::commons_script'
include_recipe 'openresty::commons_build'

chef_gem 'httpclient' do
  compile_time true if Chef::Resource::ChefGem.method_defined?(:compile_time)
end
chef_gem 'archive-zip' do
  compile_time true if Chef::Resource::ChefGem.method_defined?(:compile_time)
end
require 'httpclient'
require 'archive/zip'
require 'fileutils'

time = Time.new.strftime("%Y-%m-%d-%H%M%S")
chef_dir = Chef::Config[:file_cache_path]

if node['3scale']['config-version'].nil?
  Chef::Log.warn("3SCALE - deploying gateway with LATEST configuration version: #{time}")
  version_dir = File.join(chef_dir, time)
  mode = node['3scale']['config-source']
else
  Chef::Log.warn("3SCALE - rolling back to configuration version: #{node['3scale']['config-version']}")
  version_dir = File.join(chef_dir, node['3scale']['config-version'])
  mode = 'rollback'
end

if mode == '3scale'
  # create directory to store downloaded configuration
  directory version_dir do
    owner node['openresty']['user']
    recursive true
    action :create
  end

  ruby_block 'fetch configuration files from 3scale' do
    block do
      Helpers.fetch_3scale_config(node['3scale']['admin-domain'],
                                  node['3scale']['provider-key'],
                                  version_dir)
    end
    action :run
  end
elsif mode == 'url'
  # create directory to store downloaded configuration
  directory version_dir do
    owner node['openresty']['user']
    recursive true
    action :create
  end

  ruby_block 'fetch configuration files from a URL' do
    block do
      Helpers.fetch_from_url(node['3scale']['config-url'], version_dir)
    end
    action :run
  end
elsif mode == 'local'
  # copy configuration files located at files/default/config
  remote_directory version_dir do
    source 'config'
    owner node['openresty']['user']
    group node['openresty']['group']
    mode '0755'
    files_owner node['openresty']['user']
    files_group node['openresty']['group']
    files_mode '0644'
    action :create
  end
end

# create links for configuration files that should be used
# in the nginx configuration directory
ruby_block 'symlink configuration files' do
  block do
    Helpers.link_files(version_dir, node['openresty']['dir'])
  end
  action :run

  # reload nginx if it was already running
  if node['openresty']['service']['start_on_boot']
    notifies :reload, node['openresty']['service']['resource']
  end
end

include_recipe 'openresty::commons_cleanup'
unless node['openresty']['service']['recipe'].nil?
  include_recipe(node['openresty']['service']['recipe'])
end
