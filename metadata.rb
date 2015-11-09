name             'chef-3scale'
maintainer       '3scale Inc.'
maintainer_email 'support@3scale.net'
license          'MIT'
description      'Install and configures the 3scale API gateway'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.2'

supports 'ubuntu'
supports 'centos'

depends 'openresty'
