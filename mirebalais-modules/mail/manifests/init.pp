class mail()
{
	package { 'sendmail':
		ensure => installed
	}
	
	package { 'mailx':
		ensure => installed
	}
}
