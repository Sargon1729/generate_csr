#!/usr/bin/env bash
#Variables
source ./config.sh
source ./logging.sh

if rm -rf ../certs/*; then
    write_log "Successfully cleaned up all directories"
else
    write_error "Issues were encountered while cleaning"
fi
