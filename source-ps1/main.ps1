. ./logging.ps1
. ./config.ps1

write_log "----SCRIPT STARTED----"
################################################################################## Verifying config file

if ($USE_RSA -and $USE_EC) {
    write_error "Cannot enable both RSA and EC at the same time, exiting."
    break
}

if ( -not $USE_RSA -and -not $USE_EC) {
    write_error "USE_RSA and USE_EC cannot be both set to false, exiting."
    break
}

################################################################################## Create working folder
$CN = (Get-Content csr.conf | Select-String "CN" -CaseSensitive).ToString().Split("=")[-1].Trim()

if (!(Test-Path ..\certs\$CN)) {
    write_log "dir $CN does not exist"; write_log "Creating dir $CN"
    mkdir ..\certs\$CN
}

else {
    write_log "Directory $CN already exists..."
}

################################################################################## generate keys and csr
#Generate the actual key

if ($GENERATE_KEY) {
    write_log "Generating new RSA key pair..."
    if ($USE_RSA) {
        if ($ENCRYPT_KEY) {
            &$OPENSSL_BINARY genrsa -out ../certs/$CN/key.pem -$KEY_CIPHER $RSA_KEY_SIZE
            $global:rc = $LASTEXITCODE
        }


        else {
            &$OPENSSL_BINARY genrsa -out ../certs/$CN/key.pem $RSA_KEY_SIZE
            $global:rc = $LASTEXITCODE
        }

    }

    if ($USE_EC) {
        write_log "Generating new EC key pair"
        if ($ENCRYPT_KEY) {
            &$OPENSSL_BINARY genpkey -algorithm EC -pkeyopt ec_paramgen_curve:$EC_CURVE -out ../certs/$CN/key.pem "-$KEY_CIPHER"
            $global:rc = $LASTEXITCODE
        }


        else {
            &$OPENSSL_BINARY genpkey -algorithm EC -pkeyopt ec_paramgen_curve:$EC_CURVE -out ../certs/$CN/key.pem
            $global:rc = $LASTEXITCODE
        }

    }


    if ($rc -eq 0) {
        write_success "Successfully generated private key"
    }
    else {
        write_error "Errors encountered when generating private key"
        break
    }
}

#Generate the csr
if (Test-Path ..\certs\$CN\key.pem) {
    if ($ENCRYPT_KEY) {
        write_log "Encrypted key password required for CSR"
    }

    &$OPENSSL_BINARY req -new -key ../certs/$CN/key.pem -out ../certs/$CN/csr.csr -config csr.conf

    if ($LASTEXITCODE -eq 0) {
        write_success "Successfully generated csr"
        &$OPENSSL_BINARY req -in ../certs/$CN/csr.csr --noout --text > ../certs/$CN/csr.txt

        if ($LASTEXITCODE -eq 0) {
            write_success "Successfully generated csr text output"
        }

        else {
            write_error "Errors encountered when generating csr text output"
            break
        }
    }

    else {

        write_error "errors encountered when generating csr"
        break
    }

}

else {
    write_error "Error: no key was provided, EC or RSA, check config file and select which algorithm to use."
}