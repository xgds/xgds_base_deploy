
# force a one-time 'apt-get update' before installing any packages.
# otherwise apt-get may hit the wrong servers and error out.
exec { 'apt_update':
  command => '/usr/bin/apt-get update && touch /home/vagrant/.apt-updated',
  creates => '/home/vagrant/.apt-updated',
}
Exec['apt_update'] -> Package <| |>

#################################################################
# UBUNTU PACKAGES

class ubuntu_packages {
  package { 'build-essential': }
  package { 'libmysqlclient-dev': }
  package { 'python2.7': }
  package { 'python2.7-dev': }
  package { 'python2.7-mysqldb': }
  package { 'python2.7-imaging': }
  package { 'git': }
  package { 'libevent-dev': }

  package { 'python-setuptools': }
  package { 'python-pip': }

  # handy for dev
  package { 'emacs23': }
}

class { 'ubuntu_packages': }

#################################################################
# PIP PACKAGES

class pip_packages {
  package { 'django':
    ensure => '1.4.8',
    provider => 'pip',
  }
  package { 'django-pipeline':
    provider => 'pip',
  }
  package { 'django-reversion':
    provider => 'pip',
  }
  package { 'django-sphinx':
    provider => 'pip',
  }
  package { 'pyproj':
    provider => 'pip',
  }
  package { 'iso8601':
    provider => 'pip',
  }
  package { 'pytz':
    provider => 'pip',
  }
  package { 'django-taggit':
    provider => 'pip',
    source => 'git+git://github.com/deleted/django-taggit.git#egg=django-taggit',
  }
  package { 'django-filter':
    provider => 'pip',
  }
  package { 'gdata':
    provider => 'pip',
  }
  package { 'pyzmq':
    provider => 'pip',
  }
  # this rule fixes a problem in the pyzmq permissions after install
  exec { 'pyzmq-readable':
    command => '/usr/bin/sudo /bin/chmod -R a+rX /usr/local/lib/python2.7/dist-packages/zmq && /usr/bin/touch /home/vagrant/.pyzmq-readable',
    creates => '/home/vagrant/.pyzmq-readable',
    require => Package['pyzmq'],
  }
  package { 'gevent':
    provider => 'pip',
  }
  package { 'msgpack-python':
    provider => 'pip',
  }
  package { 'zerorpc':
    provider => 'pip',
    require => [Exec['pyzmq-readable'], Package['gevent']],
  }
  package { 'ipython':
    provider => 'pip',
  }
}

class { 'pip_packages': }
Class['ubuntu_packages'] -> Class['pip_packages']

#################################################################
# MYSQL SETUP
# https://forge.puppetlabs.com/puppetlabs/mysql

class mysql_setup {
  anchor { 'mysql_setup::begin':
    before => [Class['mysql::server'],
               Class['mysql::bindings::python']],
  }

  # install mysqld server
  class { 'mysql::server':
    config_hash => {
      'root_password' => 'vagrant',
    },
  }
  # install python bindings
  class { 'mysql::bindings::python': }
  # create database
  anchor { 'mysql_setup::end':
    require => [Class['mysql::server'],
                Class['mysql::bindings::python']],
  }
}
class { 'mysql_setup': }

#################################################################
# APACHE SETUP
# https://forge.puppetlabs.com/puppetlabs/apache

class apache_setup {
  anchor { 'apache_setup::begin':
    before => [Class['apache'],
               Class['apache::mod::wsgi'],
               ]
  }
  class { 'apache':
    default_vhost => false,
  }
  apache::listen { '80': }
  apache::mod { 'rewrite': }
  class { 'apache::mod::wsgi': }
  anchor { 'apache_setup::end':
    require => [Class['apache'],
                Class['apache::mod::wsgi']],
  }
}
class { 'apache_setup': }
