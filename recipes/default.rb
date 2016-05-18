case node['monit']['install_method']
  when 'source'   then  include_recipe 'monit::source'
  when 'package'  then  package "monit"
end

cookbook_file "/etc/default/monit" do
  source "monit.default"
  owner "root"
  group "root"
  mode 0644
  only_if { platform?("ubuntu") }
end

bash "create_log_directory" do
  code <<-EOH
    mkdir -p #{File.dirname(node['monit']['log'])}
    chown -R #{node['monit']['source']['user']}:#{node['monit']['source']['group']} #{File.dirname(node['monit']['log'])}
  EOH
  only_if { node['monit']['log'] && node['monit']['log'].include?('/')}
end

template "/etc/systemd/system/monit.service" do
  source 'systemd/monit.service.erb'
  owner 'root'
  group 'root'
  mode 0644
  notifies :run, 'execute[systemctl daemon-reload]', :immediately
  only_if { platform?('ubuntu') && Chef::VersionConstraint.new('>= 15.04').include?(node['platform_version']) }
end

execute 'systemctl daemon-reload' do
  action :nothing
end

node[:monit][:include_paths].each do |include_path|
  directory include_path do
    owner  'root'
    group 'root'
    mode 0755
    action :create
    recursive true
    not_if { ::File.exists?(include_path) }
  end
end if node[:monit][:include_paths] && node[:monit][:include_paths].any?

service "monit" do
  action :enable
  supports [:start, :restart, :stop]
  provider (platform?('ubuntu') && Chef::VersionConstraint.new('>= 15.04').include?(node['platform_version'])) ? Chef::Provider::Service::Systemd : nil
end

template "/etc/monit/monitrc" do
  owner "root"
  group "root"
  mode 0700
  source 'monitrc.erb'
  notifies :restart, resources(:service => "monit"), :immediately
end
