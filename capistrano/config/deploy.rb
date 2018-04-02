namespace :deploy do
  desc 'Deploys the app with puppet'
  task :default do
    run("cd /etc/puppet && git pull")
    run("cd /etc/puppet && chmod 0750 gem-update.sh && ./gem-update.sh")
    run("cd /etc/puppet && chmod 0750 puppet-apply.sh && ./puppet-apply.sh site")
  end
end
