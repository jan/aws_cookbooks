include_recipe "deploy"

node[:deploy].each do |application, deploy|
  if deploy[:application_type] != 'rails'
    Chef::Log.warn("Skipping figaro::deploy application #{application} as it is not an Rails app")
    next
  end

  content = {
    deploy[:environment]["RAILS_ENV"] => deploy[:environment_variables].to_hash
  }
  
  shared_file_name = ::File.join(deploy[:deploy_to], 'shared', 'config', 'application.yml')
  file shared_file_name do
    mode '0600'
    owner deploy[:user]
    group deploy[:group]
    content YAML::dump(content)
  end
  
  link_name = ::File.join(deploy[:current_path], 'config', 'application.yml')
  link shared_file_name do
    to link_name
  end
end