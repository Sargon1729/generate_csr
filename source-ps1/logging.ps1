function write_log {

    param(
        [string]$Message
    )
    $date = get-date -Format "dd/MM/yyyy hh:mm:ss"
    $LOGFILE = 'log.txt'
    "$date $Message" | Out-File $LOGFILE -Append -Encoding ascii
    Write-Host "$date $Message" -ForegroundColor Cyan
}

function write_error {

    param(
        [string]$Message
    )
    $date = get-date -Format "dd/MM/yyyy hh:mm:ss"
    $LOGFILE = 'log.txt'
    "$date $Message" | Out-File $LOGFILE -Append -Encoding ascii
    Write-Host "$date $Message" -ForegroundColor Red
}

function write_success {

    param(
        [string]$Message
    )
    $date = get-date -Format "dd/MM/yyyy hh:mm:ss"
    $LOGFILE = 'log.txt'
    "$date $Message" | Out-File $LOGFILE -Append -Encoding ascii
    Write-Host "$date $Message" -ForegroundColor Green
}

function write_note {

    param(
        [string]$Message
    )
    $date = get-date -Format "dd/MM/yyyy hh:mm:ss"
    $LOGFILE = 'log.txt'
    "$date $Message" | Out-File $LOGFILE -Append -Encoding ascii
    Write-Host "$date $Message" -ForegroundColor Yellow
}