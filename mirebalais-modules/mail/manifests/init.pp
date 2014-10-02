class mail()
{
	package { 'sendmail':
		ensure => installed
	}
	
	package { 'bsd-mailx':
		ensure => installed
	}
}
