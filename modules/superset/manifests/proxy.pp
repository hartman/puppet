# == Class superset::proxy
# Sets up a WMF HTTP LDAP auth proxy.
#
class superset::proxy {

    class { '::httpd':
        modules => ['proxy_http',
                    'proxy',
                    'headers',
                    'auth_basic',
                    'authnz_ldap']
    }

    include ::passwords::ldap::production

    $proxypass = $passwords::ldap::production::proxypass

    # Set up the VirtualHost
    httpd::site { 'superset.wikimedia.org':
        content => template('superset/superset.wikimedia.org.erb'),
    }

    ferm::service { 'superset-http':
        proto  => 'tcp',
        port   => '80',
        srange => '$CACHES',
    }
}
