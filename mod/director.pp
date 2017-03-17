# == Class icingaweb2::mod::director
#
class icingaweb2::mod::director (
  $git_repo              = 'https://github.com/Icinga/icingaweb2-module-director.git',
  $git_revision          = undef,
  $install_method        = 'git',
  $web_root              = $::icingaweb2::params::web_root,
  $director_db_name      = undef,
  $director_db_user      = undef,
  $director_db_pass      = undef,
  $director_db_host      = undef,
  $transport             = 'api',
  $transport_host        = $fqdn,
  $transport_port        = '5665',
  $director_api_user 	 = "director",
  $director_api_password = "sdusd78762z1hjnassiaod8s9" 
) {
  require ::icingaweb2

  ::icinga2::object::apiuser { 'apiuser director':
    ensure => present,
    apiuser_name => $::icingaweb2::mod::director::director_api_user,
    password => $::icingaweb2::mod::director::director_api_password,
    permissions => [ "*" ],
    target => '/etc/icinga2/conf.d/api-users.conf',
  } ->

  mysql::db { $director_db_name:
    user     => $director_db_user,
    password => $director_db_pass,
    host     => $director_db_host,
    grant    => ['ALL']
  }

  file { '/etc/icingaweb2/modules/director':
    ensure => directory,
    owner => $::icingaweb2::config_user,
    group => $::icingaweb2::config_group,
    mode => $::icingaweb2::config_file_mode,
  }

  file { "${web_root}/modules/director":
    ensure => directory,
    owner => $::icingaweb2::config_user,
    group => $::icingaweb2::config_group,
    mode => $::icingaweb2::config_file_mode,
  }

  vcsrepo { "icingaweb2director":
    ensure   => present,
    path     => "${web_root}/modules/director",
    provider => 'git',
    revision => $git_revision,
    source   => $git_repo,
  } ->

  file { '/etc/icingaweb2/enabledModules/director':
    ensure => link,
    target => '/usr/share/icingaweb2/modules/director',
  }

  Ini_setting { 
    key_val_separator => ' = ',
    path => '/etc/icingaweb2/resources.ini',
    section => 'Director DB',
  }

  ini_setting { 
    'Director DB type':
      setting => 'type',
      value => '"db"';
    'Director DB db':
      setting => 'db',
      value => '"mysql"';
    'Director DB host':
      setting => 'host',
      value => '"localhost"';
    'Director DB dbname':
      setting => 'dbname',
      value => "\"$director_db_name\"";
    'Director DB username':
      setting => 'username',
      value => "\"$director_db_user\"";
    'Director DB password':
      setting => 'password',
      value => "\"$director_db_pass\"";
    'Director DB charset':
      setting => 'charset',
      value => '"utf8"';
  }

  ini_setting { 'director db':
    section => 'db',
    path => '/etc/icingaweb2/modules/director/config.ini',
    setting => 'resource',
    value => '"Director DB"',
    require => File['/etc/icingaweb2/modules/director'],
  } ->

  ini_setting {
    'endpoint':
      path => '/etc/icingaweb2/modules/director/kickstart.ini',
      section => 'config',
      setting => 'endpoint',
      value => "\"$fqdn\"";
    'host':
      path => '/etc/icingaweb2/modules/director/kickstart.ini',
      section => 'config',
      setting => 'host',
      value => "\"$transport_host\"";
    'port':
      path => '/etc/icingaweb2/modules/director/kickstart.ini',
      section => 'config',
      setting => 'port',
      value => "\"$transport_port\"";
    'username':
      path => '/etc/icingaweb2/modules/director/kickstart.ini',
      section => 'config',
      setting => 'username',
      value => "\"$director_api_user\"";
    'password':
      path => '/etc/icingaweb2/modules/director/kickstart.ini',
      section => 'config',
      setting => 'password',
      value => "\"$director_api_password\"";
  } ->

  exec { 'Icinga director DB migrate':
    command => '/usr/bin/icingacli director migration run',
    onlyif => '/usr/bin/icingacli director migration pending',
    require => Mysql::Db["$director_db_name"]
  } ->

  exec { 'Icinga Director Kickstart':
    command => '/usr/bin/icingacli director kickstart run',
    onlyif  => '/usr/bin/icingacli director kickstart required',
    require => Exec['Icinga director DB migrate'],
  } 

}
