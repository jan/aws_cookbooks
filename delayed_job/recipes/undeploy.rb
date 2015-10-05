node[:deploy].each do |application, deploy|
  if deploy[:application_type] != 'rails'
    Chef::Log.warn("Skipping delayed_job::undeploy application #{application} as it is not an Rails app")
    next
  end
  
  if File.exist?(File.join(deploy[:current_path], 'script', 'delayed_job'))
    delayed_job_command = "script/delayed_job"
  elsif File.exist?(File.join(deploy[:current_path], 'bin', 'delayed_job'))
    delayed_job_command = "bin/delayed_job"
  else
    Chef::Log.warn("Skipping delayed_job::undeploy application #{application} as no script/delayed_job or bin/delayed_job exists")
    next
  end

  execute "(Re)starting delayed job for #{application}" do
    cwd deploy[:current_path]
    command "#{delayed_job_command} -n 5 stop"
    user deploy[:user]
  end
end