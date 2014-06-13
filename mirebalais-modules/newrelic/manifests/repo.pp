class newrelic::repo (
    $apt_repo = 'http://apt.newrelic.com/debian/') {

    file { '/etc/apt/sources.list.d/newrelic.list':
        ensure => present,
        content => "deb ${apt_repo} newrelic non-free",
    }

    Exec['newrelic-add-apt', 'newrelic-apt-get-update'] {
        path +> ['/usr/local/sbin', '/usr/local/bin', '/usr/sbin', '/usr/bin', '/sbin', '/bin']
    }

    exec { newrelic-add-apt:
        unless  => 'apt-key list | grep 548C16BF',
        command => 'wget -O- http://download.newrelic.com/548C16BF.gpg | apt-key add -',
    }
    
    exec { newrelic-apt-get-update:
        refreshonly => true,
        subscribe   => Exec["newrelic-add-apt"],
        command     => "apt-get update",
    }
}
