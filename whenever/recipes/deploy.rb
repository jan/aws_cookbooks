include_recipe "deploy"

node[:deploy].each do |application, deploy|
  if deploy[:application_type] != 'rails'
    Chef::Log.warn("Skipping whenever::deploy application #{application} as it is not an Rails app")
    next
  end

  unless File.exist?(File.join(deploy[:current_path], 'config', 'schedule.rb'))
    Chef::Log.warn("Skipping whenever::deploy application #{application} as no config/schedule.rb exists")
    next
  end

  layer_name = node[:opsworks][:instance][:layers].first
  layer = node[:opsworks][:layers][layer_name]
  Chef::Log.info("layer[#{layer_name}]: " + layer.inspect)
  
  instances = layer[:instances]
  instance_hostnames = instances.keys.sort
  Chef::Log.info("instance_hostnames: " + instance_hostnames.inspect)
  integrator_hostname = instance_hostnames.first
  Chef::Log.info("integrator_hostname: " + integrator_hostname.inspect)
  number_of_instances = instances.count
  Chef::Log.info("number_of_instances: " + number_of_instances.inspect)
  
  roles = [
    node[:opsworks][:instance][:hostname],
    node[:opsworks][:instance][:hostname].sub(/\d+$/, '')
  ]
  roles << "integrator" if node[:opsworks][:instance][:hostname] == integrator_hostname
  
  if m = node[:opsworks][:instance][:hostname].match(/(\d+)$/)
    host_number = m[1].to_i
    roles << "mod_2_0" if host_number % 2 == 0
    roles << "mod_2_1" if host_number % 2 == 1

    roles << "mod_3_0" if host_number % 3 == 0
    roles << "mod_3_1" if host_number % 3 == 1
    roles << "mod_3_2" if host_number % 3 == 2

    roles << "mod_5_0" if host_number % 5 == 0
    roles << "mod_5_1" if host_number % 5 == 1
    roles << "mod_5_2" if host_number % 5 == 2
    roles << "mod_5_3" if host_number % 5 == 3
    roles << "mod_5_4" if host_number % 5 == 4
  else
    host_number = ""
  end
  Chef::Log.info("roles: " + roles.inspect)
  Chef::Log.info("host_number: " + host_number.inspect)
  
  execute "Create cron jobs for #{application}" do
    cwd deploy[:current_path]
    command "bundle exec whenever --set 'environment=#{deploy[:environment]["RAILS_ENV"]}&app_name=#{application}&hostname=#{node[:opsworks][:instance][:hostname]}&hostnr=#{host_number}&instances=#{number_of_instances}' --roles '#{roles.join(",")}' --update-crontab '#{application}'"
    user deploy[:user]
  end
end