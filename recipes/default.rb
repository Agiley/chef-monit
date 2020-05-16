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

# Clear out old directories if they exist and already have samples etc in them
directories           =   [
  node["monit"]["config"]["available_path"],
  node["monit"]["config"]["enabled_path"]
]

directories.each do |dir|
  directory dir do
    action :delete
    recursive true
    only_if { ::File.exists?(dir) }
  end
  
  directory dir do
    owner  'root'
    group 'root'
    mode 0755
    action :create
    action :create
    not_if { ::File.exists?(dir) }
  end
end

node["monit"]["include_paths"].each do |include_path|
  directory ::File.dirname(include_path) do
    owner  'root'
    group 'root'
    mode 0755
    action :create
    recursive true
    not_if { ::File.exists?(::File.dirname(include_path)) }
  end
end if node["monit"]["include_paths"] && node["monit"]["include_paths"].any?

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

service "monit" do
  action :enable
  supports [:start, :restart, :stop]
end

configure_mail_server = (!node["monit"]["mail"]["server"]["host"].to_s.empty? && !node["monit"]["mail"]["server"]["port"].nil? && node["monit"]["mail"]["server"]["port"] > 0 && !node["monit"]["mail"]["server"]["username"].to_s.empty? && !node["monit"]["mail"]["server"]["password"].to_s.empty?)
configure_mail_format = (!node["monit"]["mail"]["format"]["from"].to_s.empty? && !node["monit"]["mail"]["format"]["subject"].to_s.empty? && !node["monit"]["mail"]["format"]["message"].to_s.empty?)

template "/etc/monit/monitrc" do
  owner "root"
  group "root"
  mode 0700
  source 'monitrc.erb'
  notifies :restart, resources(service: "monit"), :immediately
  
  variables(
    configure_mail_server: configure_mail_server,
    configure_mail_format: configure_mail_format
  )
end
