#!/bin/bash -e

# envsubst '$$ROUTER_HOST,$$DASHBOARD_HOST,$$NODE_HOST' < default.conf.template > /etc/nginx/conf.d/default.conf
envsubst < default.conf > /etc/nginx/conf.d/default.conf
envsubst < supervisord.conf > /etc/supervisor/conf.d/supervisord.conf
rm -rf /etc/nginx/sites-enabled/default

# Setup basic auth
USERNAME=${USERNAME:=root}
PASSWORD=${PASSWORD:=password}
sudo mkdir -p /etc/nginx/auth
htpasswd -b -c /etc/nginx/auth/htpasswd $USERNAME $PASSWORD

supervisord --nodaemon