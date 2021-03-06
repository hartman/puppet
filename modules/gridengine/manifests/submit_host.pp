# gridengine/submit_host.pp

class gridengine::submit_host {

    include ::gridengine

    package { [ 'jobutils' ]:
        ensure => present,
    }

    # T208579: Purge the legacy jmail script
    # TODO: remove after jmail has bee purged across the fleet
    file { [
        '/usr/bin/jmail',
        '/usr/share/man/man1/jmail.1',
    ]:
        ensure  => 'absent',
        require => Package['jobutils'],
    }

    package { 'gridengine-client':
        ensure  => present,
        require => Package['gridengine-common'],
    }

    file { '/var/lib/gridengine/default/common/accounting':
        ensure => link,
        target => '/data/project/.system/accounting',
    }

    gridengine::resource { "submit-${::fqdn}":
        rname  => $::fqdn,
        dir    => 'submithosts',
        config => 'gridengine/nothing.erb', # the content here doesn't actually matter
    }
}
