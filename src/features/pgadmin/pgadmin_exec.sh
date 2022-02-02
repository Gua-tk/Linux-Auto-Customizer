#!/usr/bin/env bash
pgadmin &
sleep 2  # Wait two seconds, so pgadmin can have time to init
xdg-open http://127.0.0.1:5050/browser
