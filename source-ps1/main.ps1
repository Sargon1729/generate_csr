. ./logging.ps1
. ./config.ps1

write_log "----SCRIPT STARTED----"
################################################################################## Verifying config file

if ($USE_RSA -and $USE_EC) {
    write_error "Cannot enable both RSA and EC at the same time"
}

if ( -not $USE_RSA -and -not $USE_EC) {
    write_error "USE_RSA and USE_EC cannot be both set to false"
}

################################################################################## Create working folder
$CN= (Get-Content csr.conf | Select-String "CN" -CaseSensitive).ToString().Split("=")[-1].Trim()

if ()