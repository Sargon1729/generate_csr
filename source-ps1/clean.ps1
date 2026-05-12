. ./logging.ps1
. ./config.ps1

Remove-Item ..\certs -Force -Recurse
if ($LASTEXITCODE -eq 0) {write_log "Successfully cleaned up all directories"}

else {write_error "Issues were encountered while cleaning"}