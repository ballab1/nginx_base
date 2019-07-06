#!/bin/bash

: ${WWW_UID:?"Environment variable 'WWW_UID' not defined in '${BASH_SOURCE[0]}'"}

nginx.updateConfig 'root' "$WWW" default.application

crf.fixupDirectory "$WWW" "$WWW_UID"
crf.fixupDirectory /var/lib/nginx/html "$WWW_UID"
crf.fixupDirectory /var/nginx "$NGINX_UID"
#crf.fixupDirectory /var/nginx/client_body_temp "$WWW_UID"
[ -d /var/log/nginx ] || mkdir -p /var/log/nginx

chmod a+rx /var/lib/nginx/html
chmod a+rx /var/lib/nginx
chmod a+rx /var/lib

# nginx:  permit runtime config based on
if [ "${NGINX_DEBUG:-0}" -ne 0 ] || [ -f /var/log/.nginx.debug ]; then
    if [ -d /usr/lib/nginx/modules.nodebug ]; then
        term.log '    running DEBUG version of nginx\n'
        rm /usr/lib/nginx/modules
        ln -s /usr/lib/nginx/modules.debug /usr/lib/nginx/modules
    else
        term.log "    no DEBUG version of 'nginx'\n" 'warn'
    fi

    # add "error_log /var/log/nginx_error.log debug;"  to nginx.conf
    declare  __file=/etc/nginx/nginx.conf
    term.log "    updating '${__file}' to log DEBUG information"'\n' 'white'
    sed -Ei -e "s|^error_log\s+.*$|error_log /var/log/nginx_error.log debug;|" "$__file"
fi
