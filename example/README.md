# this is how I currently use it all

in hiera or however you assign modules to your hosts, use this module, and it should drop a complete running icinga2 server incl

- icinga2 incl perf data in some graphite host 
- apache2 configured for icingaweb2
- icingaweb2 incl.
-- mod graphite perf data
-- mod director alive and kickstarted
-- mod businessprocess 

