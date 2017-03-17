# puppet-icingaweb2-director
puppet dropin for icingaweb2 to install and configure director

this is meant to be a dropin for the icingaweb2 puppet module https://github.com/Icinga/puppet-icingaweb2 which will install and configure (incl kickstart) the director module https://github.com/Icinga/icingaweb2-module-director 

Requires the usage of icingaweb2 module as it will use some parameters which are initialized before.
Please see the examples how to use it

Requirements:

Most requirements will be fulfilled by the other modules that you used already when you arrived here

1. have icinga2 api enabled, otherwise kickstart will not succeed

in some manifest that wraps your icinga2 server : 

  class { '::icinga2::feature::api':
    accept_commands => true,
  }

the api user which is required to kickstart director will created automatically. You should just change username & password if you want to 

2. then, in your icingaweb2 manifest, just use the new module you dropped into (example) /etc/puppetlabs/code/environments/production/modules/icingaweb2/manifests/mod/ :

  class { '::icingaweb2::mod::director':
    director_db_name => 'icinga2director',
    director_db_user => 'icinga2director',
    director_db_pass => 'XXXXXXXXX',
    director_db_host => 'localhost'
  } ->


