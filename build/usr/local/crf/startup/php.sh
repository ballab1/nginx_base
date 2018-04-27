#!/bin/bash

php.fixupDirectory "$RUN_DIR"
php.fixupDirectory "$SESSIONS_DIR"
php.fixupDirectory "$WORKING_DIR"

chown "${www['user']}":"${www['group']}" -R "$SESSIONS_DIR"
chown "${www['user']}":"${www['group']}" -R "$RUN_DIR"
chown "${www['user']}":"${www['group']}" -R "$WORKING_DIR" 

declare iniFile=/etc/php5/php.ini
sed -i -e "s|^.*date.timezone\s*=.*$|date.timezone = ${TZ}|" \
       -e "s|^.*session.save_path\s*=.*$|session.save_path = \"${SESSIONS_DIR}\"|" \
       -e "s|^.*open_basedir\s*=.*$|open_basedir = ${WORKING_DIR}|" "$iniFile"
       
declare cnfFile=/etc/php5/conf.d/php5-fpm.conf
sed -i -e "s|^.*chdir\s*=.*$|chdir = ${WORKING_DIR}|" "$cnfFile" 




