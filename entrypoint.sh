#!/bin/sh

# Substitute environment variables in the template
envsubst < /usr/share/nginx/html/index.html.template > /usr/share/nginx/html/index.html

# Start nginx
nginx -g 'daemon off;'
