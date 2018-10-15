# This role sets up a grid compute node in the Toolforge model.
#
# On its own, this sets up a working node of the grid, but it is
# useless without a more specific role from profile::toolforge::grid::node::* that
# will add functionality and place it on queues or hostgroups.

class profile::toolforge::grid::compute (
    $etcdir = hiera('profile::toolforge::etcdir'),
    $swap_partition = hiera('profile::toolforge::grid::compute::swap_partition'),
    $tmp_partition = hiera('profile::toolforge::grid::compute::tmp_partition'),
){
    # include ::toollabs::queue::continuous
    # include ::toollabs::queue::task
    class { '::sonofgridengine':
        etcdir  => $etcdir,
    }

    include ::profile::toolforge::grid::exec_environ
    # include ::profile::toolforge::grid::hba

    motd::script { 'exechost-banner':
        ensure => present,
        source => "puppet:///modules/profile/toolforge/40-${::labsproject}-exechost-banner.sh",
    }

    file { "${profile::toolforge::grid::base::store}/execnode-${::fqdn}":
        ensure  => file,
        owner   => 'root',
        group   => 'root',
        mode    => '0444',
        require => File[$profile::toolforge::grid::base::store],
        content => "${::ipaddress}\n",
    }

    if $tmp_partition {
        labs_lvm::volume { 'separate-tmp':
            size      => '16GB',
            mountat   => '/tmp',
            mountmode => '1777',
            options   => 'nosuid,noexec,nodev,rw',
        }
    }

    if $swap_partition {
        labs_lvm::swap { 'big':
            size => inline_template('<%= @memorysize_mb.to_i * 3 %>MB'),
        }
    }
}