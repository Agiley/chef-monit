def find_provider
  if Chef::VersionConstraint.new('>= 15.04').include?(node['platform_version'])
    service_provider = Chef::Provider::Service::Systemd
  # Upstart init-script is not provided for 14.04 for the package installation
  #elsif Chef::VersionConstraint.new('>= 12.04').include?(node['platform_version'])
    #service_provider = Chef::Provider::Service::Upstart
  else
    service_provider = nil
  end
  service_provider
end
