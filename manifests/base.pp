include apt
include stdlib

# force a one-time 'apt-get update' before installing any packages.
# otherwise apt-get may hit the wrong servers and error out.
#exec { 'apt_update':
#  command => "/usr/bin/apt-get update && touch /home/$user/.apt-updated",
#  creates => "/home/$user/.apt-updated",
#}
#Exec['apt_update'] -> Package <| |>

#################################################################
# UBUNTU PACKAGES

class ubuntu_packages {
  package { 'ntp': }
  package { 'build-essential': }
  package { 'nfs-common': }
  package { 'python2.7': }
  package { 'python-dev': }
  package { 'python-imaging': }
  package { 'python-scipy': }
  package { 'git': }
  package { 'libevent-dev': }
  package { 'ruby-full':}
  package { 'python-setuptools': }
  package { 'python-pip': }
  package { 'npm':}
  package { 'nodejs-legacy':}
  package { 'subversion':}
  package { 'gkermit':}
  package { 'couchdb':}
  package { 'libproj-dev': }
  package { 'gdal-bin': }
    
  # optional - for dev
  package { 'emacs': }

  # optional - includes useful 'reindent.py' script for dev
  package { 'python-examples': }

  # optional - provides useful 'ack' command for dev
  package { 'ack-grep': }
  file { '/usr/bin/ack':
    ensure => link,
    target => '/usr/bin/ack-grep',
    require => Package['ack-grep'],
  }

  # optional - needed for pykml
  package { 'python-lxml': }

  file { 'no_transparent_huge_pages':
    path => '/etc/default/grub',
    ensure => file,
    content => file("/home/$user/puppet/xgds_base_deploy/config-files/grub-defaults"),
  }

  exec { 'grub-setup':
    command => '/usr/sbin/grub-mkconfig -o /boot/grub/grub.cfg',
  }
}

class { 'ubuntu_packages': }

#################################################################
# MARIA DB PACKAGE Source

class mariadb_packages {
   apt::key {'mariadb':
      key => '0xcbcb082a1bb943db',
      key_server => 'hkp://keyserver.ubuntu.com:80',
   }

   apt::source { "mariadb":
        location        => "http://ftp.utexas.edu/mariadb/repo/10.0/ubuntu",
        release         => "trusty",
        repos           => " main",
        include_src     => false
   }
}

class { 'mariadb_packages': }

#################################################################
# PIP PACKAGES

class pip_packages {
  package { 'django':
    ensure => '1.7.3',
    provider => 'pip',
  }
  package { 'django-pipeline':
    provider => 'pip',
  }
  package { 'django-compressor':
    provider => 'pip',
  }
  package { 'pyScss':
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
    source => 'git+git://github.com/tamarmot/django-taggit.git#egg=django-taggit',
  }
  package { 'django-filter':
    provider => 'pip',
    source => 'git+https://github.com/alex/django-filter.git@d9f3b20973c35da3f2746b1e445249ac51b36bae#egg=django_filter-0.5.5a1-py2.6-dev',
  }
  package { 'gdata':
    provider => 'pip',
  }
  package { 'pyzmq':
    provider => 'pip',
  }
  # this rule fixes a problem in the pyzmq permissions after install
  exec { 'pyzmq-readable':
    command => "/usr/bin/sudo /bin/chmod -R a+rX /usr/local/lib/python2.7/dist-packages/zmq && /usr/bin/touch /home/$user/.pyzmq-readable",
    creates => "/home/$user/.pyzmq-readable",
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
  package { 'tornado':
    provider => 'pip',
  }

  package { 'django-tagging':
    provider => 'pip',
  }

  # Lets us run git from python to check out code
  package { 'GitPython':
    provider => 'pip',
  }

  package { 'rdflib':
    provider => 'pip',
    ensure => '2.4.2',
  }

  # optional - handy for debugging
  package { 'django-debug-toolbar':
    provider => 'pip',
  }

  # optional - needed for manage.py lint
  package { 'pylint':
    provider => 'pip',
  }
  package { 'pep8':
    provider => 'pip',
  }
  package { 'django-bower':
    provider => 'pip',
  }
  # this doesn't work as expected; replaced with exec resource below
  #package { 'closure-linter':
  #  source => 'http://closure-linter.googlecode.com/files/closure_linter-latest.tar.gz',
  #  provider => 'pip',
  #}
  exec { 'closure-linter':
     command => "/usr/bin/pip install http://closure-linter.googlecode.com/files/closure_linter-latest.tar.gz && touch /home/$user/.installed-closure-linter",
     creates => "/home/$user/.installed-closure-linter",
     require => Package['python-pip'],
  }

  # optional - for kml validation during testing
  package { 'pykml':
    provider => 'pip',
    require => Package['python-lxml'],
  }

  # optional - improves manage.py test
  package { 'django-discover-runner':
    provider => 'pip',
  }

}

class { 'pip_packages': }
Class['ubuntu_packages'] -> Class['pip_packages']

#################################################################
# RUBY GEM PACKAGES

class gem_packages {
  package { 'compass':
    provider => 'gem',
    ensure => '0.12.7',
  }
  package { 'sass':
    provider => 'gem',
  }
  package { 'json':
    provider => 'gem',
  }
  package { 'modular-scale':
   provider => 'gem',
   ensure => '1.0.6'
  }
}

class { 'gem_packages': }
Class['ubuntu_packages'] -> Class['gem_packages']

#################################################################
# NPM PACKAGES

class npm_packages {
  package { 'yuglify':
    provider => 'npm',
  }
  package { 'bower':
    provider => 'npm',
  }
}

class { 'npm_packages': }
Class['ubuntu_packages'] -> Class['npm_packages']

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
    package_name => 'mariadb-server',
    root_password => 'vagrant',
    override_options => {
      'mysqld' => {
        'plugin-load' => 'ha_tokudb',
      }
    }
  }
  # install python bindings
  class { 'mysql::bindings':
  	python_enable => true,
  }
  anchor { 'mysql_setup::end':
    require => [Class['mysql::server'],
                Class['mysql::bindings::python'],
		Class['mariadb_packages']],
  }
  # Install dev packages last so we get right version to match server
  package { 'libmariadbclient-dev': }
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
