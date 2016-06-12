# Override for Opsworks as a result of bug causing postgres8 install to fail.
# Should be placed in the following path from the custom cookbook repository root: 
# /opsworks_postgresql/recipes/client_install.rb
#
# Don't forget your standard metadata file in /opsworks_postgresql/metadata.rb
#
# For issue https://github.com/aws/opsworks-cookbooks/issues/347

package "postgresql-devel" do
  package_name value_for_platform(
    ["centos","redhat","fedora","amazon"] => {"default" => "postgresql94-devel"},
    "ubuntu" => {"default" => "libpq-dev"}
  )
  action :install
end

package "postgresql-client" do
  package_name value_for_platform(
    ["centos","redhat","fedora","amazon"] => {"default" => "postgresql94"},
    "default" => "postgresql-client"
  )
  action :install
end