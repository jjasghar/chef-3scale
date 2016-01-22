#
# Cookbook Name:: chef-3scale
# Recipe:: default
#
# Copyright (C) 2015 3scale Inc. (https://3scale.net)
#
# All rights reserved - Do Not Redistribute
#

# Configuration files source. Possible values: 'local', '3scale'
#   - local: files are located in the cookbook files/default/ directory
#   - 3scale: files are directly downloaded from your 3scale account
#   - url: files are directly downloaded by an url specified as an attribute
default['3scale']['config-source'] = 'local'

# URL used in the config-source = 'url' mode
# from where the config files will be fetched
# (only required if config-source == 'url')
default['3scale']['config-url'] = nil

# 3scale account information
#   - provider_key: the key that identifies you as a 3scale user
#   - admin_url: if your 3scale admin portal domain is mycompany-admin.3scale.net,
#                then the value of this attribute should be 'mycompany'
default['3scale']['provider-key'] = 'REPLACE_WITH_3SCALE_PROVIDER_KEY'
default['3scale']['admin-domain'] = 'REPLACE_WITH_3SCALE_ADMIN_URL_PART'

# To roll back to a previously deployed configuration set this attribute
# to the timestamp of that version. Example value: "2015-09-04-132622"
# If not set, the latest version will be fetched from 3scale and deployed
default['3scale']['config-version'] = nil