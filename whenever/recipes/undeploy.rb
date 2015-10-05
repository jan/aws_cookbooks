node[:deploy].each do |application, deploy|
  if deploy[:application_type] != 'rails'
    Chef::Log.warn("Skipping whenever::undeploy application #{application} as it is not an Rails app")
    next
  end
  
  unless File.exist?(File.join(deploy[:current_path], 'config', 'schedule.rb'))
    Chef::Log.warn("Skipping whenever::deploy application #{application} as no config/schedule.rb exists")
    next
  end

  execute "Remove cron jobs for #{application}" do
    cwd deploy[:current_path]
    command "bundle exec whenever --clear-crontab '#{application}'"
    user deploy["user"]
  end
end