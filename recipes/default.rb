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
  compile_time false
end
chef_gem 'rubyzip' do
  compile_time false
end

time = Time.new.strftime("%Y-%m-%d-%H%M%S")
chef_dir = Chef::Config[:file_cache_path]
dest_dir = File.join(chef_dir, time)

if node['3scale']['config-source'] == '3scale'
  # create output directory
  directory dest_dir do
    owner node['openresty']['user']
    recursive true
    action :create
  end

  ruby_block 'fetch configuration files from 3scale' do
    block do
      require 'httpclient'
      require 'zip'

      def is_config?(filename)
        ['.lua', '.conf'].include?(File.extname(filename))
      end

      def out_filename(filename)
        File.extname(filename) == '.conf' ? 'nginx.conf' : filename
      end

      def unzip(data, dest_dir)
        io = StringIO.new(data)

        ::Zip::InputStream.open(io) do |fzip|
          while entry = fzip.get_next_entry
            next unless is_config?(entry.name)
            content = fzip.read
            filename = out_filename(entry.name)
            path = File.join(dest_dir, filename)
            File.write(path, content)
          end
        end
      end

      path = '/admin/api/nginx.zip'
      url = "https://#{node['3scale']['admin-domain']}-admin.3scale.net#{path}?provider_key=#{node['3scale']['provider-key']}"
      response = HTTPClient.get(url, follows_redirect: true)
      if response.status == 200
        unzip(response.body, dest_dir)
      else
        raise 'Could not fetch files from 3scale'
      end
    end
    action :run
  end
else
  # use local configuration files from files/default/config
  remote_directory dest_dir do
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