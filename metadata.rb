name             'spartan_loggly_rsyslog'
maintainer       'Daniel Searles'
maintainer_email 'dsearles@joinspartan.com'
license          'Apache 2.0'
source_url       'https://github.com/spartansystems/spartan_loggly_rsyslog-cookbook'
description      'Configures rsyslog to send logs to Loggly'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '2.1.2'

supports 'ubuntu', '>= 12.04'

depends 'apt', '~> 2.0'
depends 'rsyslog', '~> 1.13.0'
