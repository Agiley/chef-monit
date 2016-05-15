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

if (node['monit']['log'] && node['monit']['log'].include?('/'))
  folder = File.dirname(node['monit']['log'])
  
  if (folder)
    bash "create_log_directory" do
      code <<-EOH
        mkdir -p #{folder}
        chown -R #{node['monit']['source']['user']}:#{node['monit']['source']['group']} #{folder}
      EOH
    end
  end
end

service "monit" do
  action :enable
  supports [:start, :restart, :stop]
end

template "/etc/monit/monitrc" do
  owner "root"
  group "root"
  mode 0700
  source 'monitrc.erb'
  notifies :restart, resources(:service => "monit"), :delayed
end

directory "/etc/monit/conf.d/" do
  owner  'root'
  group 'root'
  mode 0755
  action :create
  recursive true
end

service "monit" do
  action :start
end