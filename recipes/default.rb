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
    template "/etc/init.d/monit" do
      source 'init/monit.init.sh.erb'
      owner "root"
      group "root"
      mode 0755
    end
  end
end

if (node['monit']['install_method'] == 'source')
  bash "after_setup_tasks" do
    code <<-EOH
      rm -rf /etc/monitrc
      ln -s /etc/monit/monitrc /etc/monitrc
      update-rc.d monit defaults
    EOH
  end
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