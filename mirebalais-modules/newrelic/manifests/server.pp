class newrelic::server {
    include newrelic::package
    $license_key = 'ee619f9f928541a5fde6afb4a28016e9a89f137f'

    if $license_key == undef{ fail('$license_key not defined') }

    Exec['newrelic-set-license', 'newrelic-set-ssl'] {
      path +> ['/usr/local/sbin', '/usr/local/bin', '/usr/sbin', '/usr/bin', '/sbin', '/bin']
    }

    exec { "newrelic-set-license":
        unless  => "egrep -q '^license_key=${license_key}$' /etc/newrelic/nrsysmond.cfg",
        command => "nrsysmond-config --set license_key=${license_key}",
        notify => Service['newrelic-sysmond'];
    }

    exec { "newrelic-set-ssl":
        unless  => "egrep -q ^ssl=true$ /etc/newrelic/nrsysmond.cfg",
        command => "nrsysmond-config --set ssl=true",
        notify => Service['newrelic-sysmond'];
    }

    service { "newrelic-sysmond":
        enable  => true,
        ensure  => running,
        hasstatus => true,
        hasrestart => true,
        require => Class["newrelic::package"];
    }

}
