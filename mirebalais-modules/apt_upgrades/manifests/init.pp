class apt_upgrades(
    $sysadmin_email = hiera('sysadmin_email')
) {

	class { 'apt::unattended_upgrades' :
  	      origins 	          => ['${distro_id} ${distro_codename}-security'],
 	        blacklist           => ['mirebalais'],
  	      update              => '1',
  	      download            => '1',
  	      upgrade             => '1',
  	      autoclean           => '7',
  	      mail_to	            => '${sysadmin_email}',
  	      auto_fix            => true,
  	      minimal_steps       => false,
  	      install_on_shutdown => false,
  	      auto_reboot         => false,
          automaticremove     => true
	 }
}	      
