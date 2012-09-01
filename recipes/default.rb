case node['monit']['install_method']
  when 'source'   then  include_recipe 'monit::source'
  when 'package'  then  package "monit"
end

if platform?("ubuntu")
  cookbook_file "/etc/default/monit" do
    source "monit.default"
    owner "root"
    group "root"
    mode 0644
  end

  # Working init script, fix for: https://bugs.launchpad.net/ubuntu/+source/monit/+bug/993381
  if node.platform_version.to_f == 12.04
    cookbook_file "/etc/init.d/monit" do
      source "monit.init.sh"
      owner "root"
      group "root"
      mode 0755
    end
  end
end

if (node['monit']['install_method'] == 'source')
  bash "start_monit_on_boot" do
    code "update-rc.d monit defaults"
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
