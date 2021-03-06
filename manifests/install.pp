# == Class: cassandra::install
#
# Please see the README for this module for full details of what this class
# does as part of the module and how to use it.
#
class cassandra::install (
  $cassandra_package_ensure,
  $cassandra_package_name,
  $manage_dsc_repo,
  ) {

  case $::osfamily {
    'RedHat': {
      if $manage_dsc_repo == true {
        yumrepo { 'datastax':
          ensure   => present,
          descr    => 'DataStax Repo for Apache Cassandra',
          baseurl  => 'http://rpm.datastax.com/community',
          enabled  => 1,
          gpgcheck => 0,
          before   => Package[ $cassandra_package_name ],
        }
      }
    }
    'Debian': {
      if $manage_dsc_repo == true {
        include apt
        include apt::update

        apt::key {'datastaxkey':
          id     => '7E41C00F85BFC1706C4FFFB3350200F2B999A372',
          source => 'http://debian.datastax.com/debian/repo_key',
          before => Apt::Source['datastax']
        }

        apt::source {'datastax':
          location => 'http://debian.datastax.com/community',
          comment  => 'DataStax Repo for Apache Cassandra',
          release  => 'stable',
          include  => {
            'src' => false
          },
          notify   => Exec['update-cassandra-repos']
        }

        # Required to wrap apt_update
        exec {'update-cassandra-repos':
          refreshonly => true,
          command     => '/bin/true',
          require     => Exec['apt_update'],
          before      => Package[ $cassandra_package_name ]
        }
      }
    }
    default: {
      fail("OS family ${::osfamily} not supported")
    }
  }

  package { $cassandra_package_name:
    ensure => $cassandra_package_ensure,
  }
}
