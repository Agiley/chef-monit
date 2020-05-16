# reload: Reload monit so it notices the new service.  :delayed (default) or :immediately.
# action: :enable To create the monitoring config (default), or :disable to remove it.
# variables: Hash of instance variables to pass to the ERB template
# template_cookbook: the cookbook in which the configuration resides
# template_source: filename of the ERB configuration template, defaults to <LWRP Name>.conf.erb
define :monitrc, action: :enable, reload: :delayed, variables: {}, template_cookbook: "monit", template_source: nil do
  params[:template_source] ||= "#{params[:name]}.conf.erb"
  available_path  =   "/etc/monit/conf-available/#{params[:name]}.conf"
  enabled_path    =   "/etc/monit/conf-enabled/#{params[:name]}.conf"
  paths           =   [available_path, enabled_path]
  
  if params[:action] == :enable
    paths.each do |path|
      directory ::File.dirname(path) do
        owner  'root'
        group 'root'
        mode 0755
        action :create
        recursive true
        not_if { ::File.exists?(::File.dirname(path)) }
      end
    end
    
    template available_path do
      owner "root"
      group "root"
      mode 0644
      source params[:template_source]
      cookbook params[:template_cookbook]
      variables params[:variables]
      action :create
    end
    
    link enabled_path do
      to available_path
      notifies :restart, resources(service: "monit"), params[:reload]
    end
    
  else
    paths.each do |path|
      template path do
        action :delete
        notifies :restart, resources(service: "monit"), params[:reload]
      end
    end
    
  end
end
