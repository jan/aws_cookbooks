include_recipe "deploy"

node[:deploy].each do |application, deploy|
  if deploy[:application_type] != 'rails'
    Chef::Log.warn("Skipping delayed_job::deploy application #{application} as it is not an Rails app")
    next
  end

  if File.exist?(File.join(deploy[:current_path], 'script', 'delayed_job'))
    delayed_job_command = "script/delayed_job"
  elsif File.exist?(File.join(deploy[:current_path], 'bin', 'delayed_job'))
    delayed_job_command = "bin/delayed_job"
  else
    Chef::Log.warn("Skipping delayed_job::deploy application #{application} as no script/delayed_job or bin/delayed_job exists")
    next
  end

  execute "(Re)starting delayed job for #{application}" do
    cwd deploy[:current_path]
    command "/usr/bin/env RAILS_ENV=#{deploy[:rails_env]} #{delayed_job_command} -n #{node[:delayed_job][application] ? node[:delayed_job][application][:threads] : node[:delayed_job][:threads]} restart"
    user deploy[:user]
  end
end