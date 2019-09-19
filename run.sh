#!/usr/bin/env bash

mkdir -p /www/html

bash update.sh &
sleep 10
thttpd -p 80 -D -d /www/html
