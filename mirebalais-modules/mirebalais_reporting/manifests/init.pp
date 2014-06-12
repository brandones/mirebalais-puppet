class mirebalais_reporting (
	$site_domain = hiera('site_domain'),
	$tomcat = hiera('tomcat'),
){
	# install file to customize apps for production (removing export apps) or reporting server (only including export apps)
  	file { '/home/${tomcat}/.OpenMRS/appframework-config.json':
		ensure => present,
		source => 'puppet:///modules/mirebalais_reporting/appframework-config-reporting.hum.ht.json',
		owner   => $tomcat,
		group   => $tomcat,
		mode    => '0644',
		require => File["/home/${tomcat}/.OpenMRS"]
	}
}






