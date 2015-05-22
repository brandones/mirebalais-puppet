class crashplan(
  $services_ensure = hiera('services_ensure'),
  $services_enable = hiera('services_enable'),
){

  wget::fetch { 'download-crashplan':
    source      => 'http://download.crashplan.com/installs/linux/install/CrashPlan/CrashPlan_3.0.3_Linux.tgz',
    destination => '/usr/local/crashplan.tgz',
    timeout     => 0,
    verbose     => false,
  }

  Exec['crashplan-unzip', 'crashplan-install'] {
        path +> ['/usr/local/sbin', '/usr/local/bin', '/usr/sbin', '/usr/bin', '/sbin', '/bin']
  }

  exec { 'crashplan-unzip':
    cwd     => '/usr/local',
    command => 'tar -C CrashPlanPRO-install -xzf /usr/local/crashplan.tgz',
    require => [ Wget::Fetch['download-crashplan'] ],
  }

  exec { 'crashplan-install':
    cwd     => '/usr/local/CrashPlanPRO-install',
    command => '/usr/local/CrashPlanPRO-install/install.sh',
    require => [ Exec['crashplan-unzip'], File['/usr/local/CrashPlanPRO-install/install.sh'] ],
  }

  file_line { 'Modify my.service.xml':
    path  => '/usr/local/crashplan/conf/my.service.xml',  
    line  => '<serviceHost>0.0.0.0</serviceHost>',
    match => '^<serviceHost>127.0.0.1</serviceHost>',
    ensure  => present,
    require => [ Exec['crashplan-install'] ],
  }

  if $services_enable {
    $require = [ File['/etc/init.d/crashplan'], File['/usr/local/crashplan/bin/CrashPlanEngine'], File['/usr/local/crashplan/conf/my.service.xml'] ] 
]
  } else {
    $require = []
  }

  service { 'crashplan':
    ensure   => $services_ensure,
    enable   => $services_enable,
    provider => upstart,
    require  => $require
  }
}
