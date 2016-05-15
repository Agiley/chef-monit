monit_url     =   "http://mmonit.com/monit/dist/monit-#{node['monit']['version']}.tar.gz"

include_recipe "build-essential"

src_filepath  =   "#{Chef::Config['file_cache_path'] || '/tmp'}/monit-#{node['monit']['version']}.tar.gz"
packages      =   ['libssl-dev', 'libpam0g-dev', 'libreadline-gplv2-dev']

node.set['monit']['binary_path'] = "/usr/local/bin/monit"

packages.each do |dev_pkg|
  package dev_pkg
end

remote_file monit_url do
  source monit_url
  path src_filepath
  backup false
end

configure_flags   =   (node['monit']['source']['configure_flags'] && node['monit']['source']['configure_flags'].any?) ? node['monit']['source']['configure_flags'].join(" ") : ""
monit_user        =   (node['monit']['source']['user'])   ?   node['monit']['source']['user']   :   "root"
monit_group       =   (node['monit']['source']['group'])  ?   node['monit']['source']['group']  :   "root"

bash "compile_monit_source" do
  cwd ::File.dirname(src_filepath)
  code <<-EOH
    tar zxf #{::File.basename(src_filepath)} -C #{::File.dirname(src_filepath)}
    cd monit-#{node['monit']['version']} && ./configure #{configure_flags}
    make && make install
    mkdir -p /etc/monit/conf.d/
    chown #{monit_user}:#{monit_group} /etc/default/monit
    chown -R #{monit_user}:#{monit_group} /etc/monit
  EOH
end

bash "after_setup_tasks" do
  code <<-EOH
    rm -rf /etc/monitrc
    ln -s /etc/monit/monitrc /etc/monitrc
    update-rc.d monit defaults
  EOH
end
