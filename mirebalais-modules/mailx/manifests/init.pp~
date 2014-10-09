class mail (
	$smtp_username = hiera('smtp_username'),
	$smtp_userpassword = hiera('smtp_userpassword'),
	){
	
	package { 'msmtp':
		ensure => installed,
	}

	package { 'mailutils':
		ensure => installed,
	}

	package { 'bsd-mailx':
		ensure => installed,
	}
	
	package { 'msmtp-mta':
		ensure => installed,
	}

	exec { 'msmtp info':
	    command     => 'msmtp --serverinfo --host=smtp.gmail.com --tls=on --tls-certcheck=off',
	    user		=> 'root',
	    subscribe   => [ Package['msmtp'], Package['mailutils'], Package['bsd-mailx'] ]
  	}

  	file { '/etc/msmtprc':
	    ensure  => file,
    	group   => mail,
    	mode    => '0660',
	    content => template('mailx/msmtprc.erb'),
	    require => Package['msmtp']
    }

    file { '/var/log/msmtp.log':
	    ensure  => file,
    	group   => mail,
    	mode    => '0660',
	    require => Package['msmtp']
    }

}
