class icinga2server ( 
  $ido_db_name = hiera('icinga2::ido::name', 'icinga2'),
  $ido_db_user = hiera('icinga2::ido::user', 'icinga2'),
  $ido_db_pass = hiera('icinga2::ido::password', 'XXXXXXXX'),
) {

  apt::key { 'icinga2':
    id      => 'F51A91A5EE001AA5D77D53C4C6E319C334410682',
    server  => 'keyserver.ubuntu.com',
  }

  class { '::icinga2':
    manage_repo => true,
    features => ['checker', 'mainlog', 'command'],
  } 

  class { '::icinga2::feature::graphite':
    host                   => 'your.graphite-host',
    port                   => 2003,
    enable_send_thresholds => true,
    enable_send_metadata   => true,
  }

  apt::source { "${lsbdistcodename}-backports":
    location => 'http://ftp.debian.org/debian',
    key => '630239CC130E1A7FD81A27B140976EAF437D05B5',
    repos => 'main',
    release => "${lsbdistcodename}-backports",
    before => Class['::icinga2']
  }

  include ::mysql::server
  include ::mysql::client

  mysql::db { $ido_db_name:
    user     => $ido_db_user,
    password => $ido_db_pass,
    host     => 'localhost',
    grant    => ['ALL']
  }

  class{ '::icinga2::feature::idomysql':
    user => $ido_db_user,
    password => $ido_db_pass,
    database => $ido_db_name,
    host => 'localhost',
    import_schema => true,
    require => Mysql::Db[$ido_db_name],
  }

  class { '::icinga2::feature::api':
    accept_commands => true,
  } 

}
