node[:deploy].each do |application, deploy|
  if deploy[:application_type] != 'rails'
    Chef::Log.warn("Skipping precompile_assets::undeploy application #{application} as it is not an Rails app")
    next
  end

  if deploy[:rails_env] != 'production'
    Chef::Log.warn("Skipping precompile_assets::undeploy application #{application} as it is not a production environment")
    next
  end

  unless File.exist?(File.join(deploy[:current_path], 'app', 'assets'))
    Chef::Log.warn("Skipping precompile_assets::undeploy application #{application} as no assets folder exists")
    next
  end
  
  execute "Remove link to assets for #{application}" do
    command "unlink #{deploy[:absolute_document_root]}/assets"
    user deploy["user"]
  end

  execute "Remove shared assets for #{application}" do
    command "rm -rf #{deploy[:deploy_to]}/shared/assets"
    user deploy["user"]
  end
end