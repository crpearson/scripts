name             'ghost'
maintainer       'Christian Nunciato'
maintainer_email 'chris@nunciato.org'
license          'Apache 2.0'
description      'Installs and configures a Ghost blog'
version          '0.1.1'

supports 'ubuntu', '>= 12.04'
supports 'centos', '>= 6.5'

depends 'apt'
depends 'build-essential'
depends 'nodejs', '~> 1.3.0'
depends 'chef-vault'
depends 'sqlite'
depends 'nginx'
depends 'runit'
depends 'git'
