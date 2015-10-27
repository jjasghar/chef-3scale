#
# Cookbook Name:: chef-3scale
# Recipe:: default
#
# Copyright (C) 2015 3scale Inc. (https://3scale.net)
#
# All rights reserved - Do Not Redistribute
#

class Chef::Recipe::Helpers
  def self.is_config?(filename)
    ['.lua', '.conf'].include?(File.extname(filename))
  end

  def self.out_filename(filename)
    File.extname(filename) == '.conf' ? 'nginx.conf' : filename
  end

  def self.unzip(data, dest_dir)
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

  def self.fetch_3scale_config(admin_domain, provider_key, dest_dir)
    path = '/admin/api/nginx.zip'
    url = "https://#{admin_domain}-admin.3scale.net#{path}?provider_key=#{provider_key}"
    response = HTTPClient.get(url, follows_redirect: true)
    if response.status == 200
      unzip(response.body, dest_dir)
    else
      raise 'Could not fetch files from 3scale'
    end
  end

  def self.link_files(from_dir, openresty_dir)
    FileUtils.symlink(Dir["#{from_dir}/*"], openresty_dir, force: true)
  end
end