class workflow_app (

) {
  exec { 'clean_workflow_app_directory':
    command => "rm /var/www/html/workflow -r -f",
    require =>  Package['apache2']
  }

  exec {'retrieve_workflow_app':
    command => "/usr/bin/wget -q http://bamboo.pih-emr.org/workflow-repo/openmrs-pwa-workflow.tar.gz -O /var/www/html/openmrs-pwa-workflow.tar.gz",
    creates => "/var/www/html/workflow/openmrs-pwa-workflow.tar.gz",
    require => Exec["clean_workflow_app_directory"]
  }

  exec { 'extract_workflow_app':
    command => "/bin/tar -xvf /var/www/html/openmrs-pwa-workflow.tar.gz",
    require => Exec["retrieve_workflow_app"]
  }

}
