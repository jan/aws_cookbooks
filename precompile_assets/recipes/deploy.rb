include_recipe "deploy"

node[:deploy].each do |application, deploy|
  if deploy[:application_type] != 'rails'
    Chef::Log.warn("Skipping precompile_assets::deploy application #{application} as it is not an Rails app")
    next
  end

  unless File.exist?(File.join(deploy[:current_path], 'app', 'assets'))
    Chef::Log.warn("Skipping precompile_assets::deploy application #{application} as no assets folder exists")
    next
  end
  
  directory "#{deploy[:deploy_to]}/shared/assets" do
    group deploy[:group]
    owner deploy[:user]
    mode "0775"
    action :create
    recursive true
  end

  execute "Link shared asset folder for #{application}" do
    command "ln -nfs #{deploy[:deploy_to]}/shared/assets #{deploy[:absolute_document_root]}/assets"
    user deploy[:user]
  end

  execute "Precompile assets for #{application}" do
    cwd deploy[:current_path]
    command "bundle exec rake assets:precompile"
    user deploy[:user]
  end
end