default["monit"]["install_method"]                        =   "package"
default["monit"]["version"]                               =   "5.4"
default["monit"]["binary_path"]                           =   "/usr/bin/monit"
default["monit"]["log"]                                   =   "syslog facility log_daemon"

default["monit"]["source"]["configure_flags"]             =   nil
default["monit"]["source"]["user"]                        =   "root"
default["monit"]["source"]["group"]                       =   "root"

default["monit"]["notify"]["email"]                       =   "notify@example.com"
default["monit"]["notify"]["options"]                     =   "NOT ON { action, instance, pid, ppid }"

default["monit"]["polling"]["period"]                     =   60
default["monit"]["polling"]["start_delay"]                =   120

default["monit"]["mail"]["server"]["host"]                =   "localhost"
default["monit"]["mail"]["server"]["port"]                =   nil
default["monit"]["mail"]["server"]["username"]            =   nil
default["monit"]["mail"]["server"]["password"]            =   nil
default["monit"]["mail"]["server"]["password_suffix"]     =   nil

default["monit"]["mail"]["format"]["subject"]             =   "$SERVICE $EVENT"
default["monit"]["mail"]["format"]["from"]                =   "monit@example.com"
default["monit"]["mail"]["format"]["message"]             =   <<-EOS
Monit $ACTION $SERVICE at $DATE on $HOST: $DESCRIPTION.
Yours sincerely,
monit
EOS

default["monit"]["web"]["port"]                           =   2812
default["monit"]["web"]["bind_to_localhost"]              =   true
default["monit"]["web"]["allowed_connections"]            =   ["localhost"]

default["monit"]["include_paths"]                         =   ["/etc/monit/conf-enabled/*.conf"]
