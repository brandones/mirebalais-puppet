class crashplan(

){

  wget::fetch { 'download':
    source      => 'http://download.crashplan.com/installs/linux/install/CrashPlan/CrashPlan_3.0.3_Linux.tgz',
    destination => '/usr/local/crashplan.tgz',
    timeout     => 0,
    verbose     => false,
  }

  exec { 'unzip':
    cwd     => '/usr/local',
    command => '/bin/tar -C CrashPlanPRO-install -xzf /usr/local/crashplan.tgz',
    require => [ Wget::Fetch['download'] ],
  }

}
