# filtertags: labs-project-deployment-prep
class role::mediawiki::videoscaler {
    system::role { 'mediawiki::videoscaler': }

    include ::base::firewall

    # Parent role
    include ::role::mediawiki::scaler

    # Profiles
    include ::profile::prometheus::apache_exporter
    include ::profile::prometheus::hhvm_exporter

    include ::profile::mediawiki::jobrunner


    # Change the apache2.conf Timeout setting
    augeas { 'apache timeout':
        incl    => '/etc/apache2/apache2.conf',
        lens    => 'Httpd.lns',
        changes => [
            'set /files/etc/apache2/apache2.conf/directive[self::directive="Timeout"]/arg 86400',
        ],
        notify  => Service['apache2'],
    }

    # TODO: change role used in beta
    # lint:ignore:wmf_styleguide
    if hiera('has_lvs', true) {
        require ::lvs::configuration
        class { '::lvs::realserver':
            realserver_ips => $::lvs::configuration::service_ips['videoscaler'][$::site]
        }
        include ::profile::mediawiki::jobrunner_tls
    }
    # lint:endignore
}
