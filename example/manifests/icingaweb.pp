class icinga2server::icingaweb(
  $web_db_name = hiera('icingaweb2::db::name', 'icingaweb2'),
  $web_db_user = hiera('icingaweb2::db::user', 'icingaweb2'),
  $web_db_pass = hiera('icingaweb2::db::password', 'XXXXXXXXXXXX'),
  $web_db_host = hiera('icingaweb2::db::host', 'localhost')
) {

  mysql::db { $web_db_name:
    user     => $web_db_user,
    password => $web_db_pass,
    host     => 'localhost',
    grant    => ['ALL'],
  }

  class { '::apache':
    mpm_module => 'prefork',
  }

  class { '::apache::mod::php': }
  class { '::apache::mod::rewrite': }

  package { "php5-curl":
    ensure => installed,
  }

  class { '::icingaweb2':
    install_method => 'git',
    initialize => true,
    manage_apache_vhost => true,
    ido_db_name => $::icinga2server::ido_db_name,
    ido_db_pass => $::icinga2server::ido_db_pass,
    ido_db_user => $::icinga2server::ido_db_user,
    web_db_name => $web_db_name,
    web_db_pass => $web_db_pass,
    web_db_user => $web_db_user,
    require => [
      Class['::Apt::Update'],
      Class['::Mysql::Server'],
    ]
  } ->

  # we may not install earlier because 
  # icingacli package will put something into 
  # /usr/share/icingaweb2 which will cause 
  # vcsrepo not to accept this as target
  package { "icingacli":
    ensure => installed,
  } ->

  augeas { 'php.ini':
    context => '/files/etc/php.ini/PHP',
    changes => ['set date.timezone Europe/Berlin',],
  } ->

  class { '::icingaweb2::mod::monitoring':
    transport      => 'local',
    transport_path => '/run/icinga2/cmd/icinga2.cmd',
  } ->

  class { '::icingaweb2::mod::businessprocess': 
  } ->

  class { '::icingaweb2::mod::director': 
    director_db_name => 'icinga2director',
    director_db_user => 'icinga2director',
    director_db_pass => 'XXXXXXXXXXXXXXX',
    director_db_host => 'localhost'
  } ->

  class { '::icingaweb2::mod::graphite':
    graphite_base_url => 'http://your.graphite-host/render?',
  }

}
