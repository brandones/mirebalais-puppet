class crashplan(

){

  wget::fetch { 'download':
    source      => 'http://download.crashplan.com/installs/linux/install/CrashPlanPRO/CrashPlanPRO_4.2.0_Linux.tgz',
    destination => '/usr/local/crashplanpro.tgz',
    timeout     => 0,
    verbose     => false,
  }

  exec { 'unzip':
    cwd     => '/usr/local',
    command => '/bin/tar -xzf /usr/local/crashplanpro.tgz',
    require => [ Wget::Fetch['download'] ],
  }
}
