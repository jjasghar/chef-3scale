name             'chef-3scale'
maintainer       '3scale Inc.'
maintainer_email 'support@3scale.net'
license          'MIT'
description      'Install and configures the 3scale API gateway'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.3.0'
issues_url       'https://github.com/3scale/chef-3scale/issues'
source_url       'https://github.com/3scale/chef-3scale'

supports 'ubuntu'
supports 'centos'

depends 'openresty'
