#!/bin/bash
set -e
export DEPLOYMENT_ID=$(python set_deployment_id.py)
if [ "${1:0:1}" = '-' ]; then
    set -- telegraf "$@"
fi

exec "$@"
