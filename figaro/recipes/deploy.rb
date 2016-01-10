include_recipe "deploy"

node[:deploy].each do |application, deploy|
  if deploy[:application_type] != 'rails'
    Chef::Log.warn("Skipping figaro::deploy application #{application} as it is not an Rails app")
    next
  end

  content = {
    deploy[:environment]["RAILS_ENV"] => deploy[:environment_variables]
  }
  
  file ::File.join(deploy[:deploy_to], 'shared', 'config', 'application.yml') do
    mode '0700'
    owner deploy[:user]
    group deploy[:group]
    content YAML::dump(content)
  end
end