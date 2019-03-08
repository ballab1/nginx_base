#!/bin/bash

: ${WWW_UID:?"Environment variable 'WWW_UID' not defined in '${BASH_SOURCE[0]}'"}

nginx.updateConfig 'root' "$WWW" default.application

crf.fixupDirectory "$WWW" "$WWW_UID"
crf.fixupDirectory /var/lib/nginx/html "$WWW_UID"
crf.fixupDirectory /var/nginx "$NGINX_UID"
#crf.fixupDirectory /var/nginx/client_body_temp "$WWW_UID"
[ -d /var/log/nginx ] || mkdir -p /var/log/nginx

chmod 755 /var/lib/nginx/html
chmod 755 /var/lib/nginx
chmod 755 /var/lib

if [ -f /var/log/.nginx.debug ] &&  [ "$(which nginx-debug)" ] ; then
    declare __file=/etc/supervisor.d/nginx.ini
    term.log "    updating '${__file}' to run DEBUG version of 'nginx'\n" 'white'
    sed -Ei \
        -e "s|^command=nginx.*$|command=nginx-debug -c /etc/nginx/nginx.conf|" \
           "$__file"

    __file=/etc/nginx/nginx.conf
    term.log "    updating '${__file}' to log DEBUG information\n" 'white'
    sed -Ei \
        -e "s|^error_log\s+.*$|error_log /var/log/nginx_error.log debug;|" \
           "$__file"
fi