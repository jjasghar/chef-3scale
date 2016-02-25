#
# Cookbook Name:: chef-3scale
# Recipe:: default
#
# Copyright (C) 2015 3scale Inc. (https://3scale.net)
#
# All rights reserved - Do Not Redistribute
#

class Chef::Recipe::Helpers
  def self.unzip(data, dest_dir)
    ::Zip::File.open_buffer(data) do |fzip|
      fzip.each do |entry|
       path = File.join(dest_dir, entry.name)
       FileUtils::mkdir_p(File.dirname(path))
       fzip.extract(entry, path) unless File.exist?(path)
      end
    end
  end

  def self.fetch_from_url(url, dest_dir)
    response = HTTPClient.get(url, follows_redirect: true)
    if response.status == 200
      unzip(response.body, dest_dir)
    else
      raise 'Could not fetch files from 3scale'
    end
  end

  def self.fetch_3scale_config(admin_domain, provider_key, dest_dir)
    path = '/admin/api/nginx.zip'
    url = "https://#{admin_domain}-admin.3scale.net#{path}?provider_key=#{provider_key}"
    fetch_from_url(url, dest_dir)
  end

  def self.link_files(from_dir, openresty_dir)
    FileUtils.symlink(Dir["#{from_dir}/*"], openresty_dir, force: true)
  end
end