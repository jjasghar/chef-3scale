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

time = Time.new.strftime("%Y-%m-%d-%H%M%S")
chef_dir = Chef::Config[:file_cache_path]
dest_dir = File.join(chef_dir, time)

directory dest_dir do
  owner node['openresty']['user']
  recursive true
  action :create
end

files = %w(nginx.sample.conf nginx.sample.lua)
files.each do |file|
  cookbook_file "#{dest_dir}/#{file}" do
    source file
    owner node['openresty']['user']
    group node['openresty']['group']
    mode 0644
  end
end

ruby_block 'symlink latest config files' do
  block do
    require 'fileutils'
    FileUtils.symlink(Dir["#{dest_dir}/*"], node['openresty']['dir'], force: true)
  end
  action :run
end

include_recipe 'openresty::commons_cleanup'
unless node['openresty']['service']['recipe'].nil?
  include_recipe(node['openresty']['service']['recipe'])
end