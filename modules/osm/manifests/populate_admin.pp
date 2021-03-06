define osm::populate_admin (
    Wmflib::Ensure $ensure      = present,
    Boolean $disable_admin_cron = false,
    Integer $hour               = 0,
    Integer $minute             = 1,
    String $weekday             = 'Tuesday',
    String $log_dir             = '/var/log/osm'
) {

    $ensure_cron = $disable_admin_cron ? {
        true    => absent,
        default => $ensure,
    }
    file { $log_dir:
        ensure => directory,
        owner  => 'postgres',
        group  => 'postgres',
        mode   => '0755',
    }
    cron { "populate_admin-${title}":
        ensure  => $ensure_cron,
        command => "/usr/bin/psql -1Xq -d ${title} -c 'SELECT populate_admin();' >> ${log_dir}/populate_admin.log 2>&1",
        user    => 'postgres',
        weekday => $weekday,
        hour    => $hour,
        minute  => $minute,
    }
    logrotate::rule { "populate_admin-${title}":
        ensure     => $ensure_cron,
        file_glob  => "${log_dir}/populate_admin.log",
        frequency  => 'weekly',
        missing_ok => true,
        rotate     => 4,
        compress   => true,
    }

}
