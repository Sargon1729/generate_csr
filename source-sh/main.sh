#!/usr/bin/env bash
#Variables
source ./config.sh
source ./logging.sh

write_log "----SCRIPT STARTED----"

################################################################################## Create working folder
#Yes I know this is really bad since it calls external programs
CN=$(cat csr.conf | grep CN | cut -d "=" -f2 | tr -d ' ')

if [[ ! -d ../certs/$CN ]]; then
    write_log "dir $CN does not exist"; write_log "Creating dir $CN"
    mkdir ../certs/$CN

else

    write_log "dir $CN exists"
fi

################################################################################## generate keys and csr
#Generate the actual key

if [[ $USE_RSA == true && $USE_EC == true ]]; then
    write_error "Cannot enable both RSA and EC at the same time"
    exit 1
fi

if $GENERATE_KEY; then
    if [ "$USE_RSA" = true ]; then
    write_log "Generating new RSA key pair..."
        if $OPENSSL_BINARY genrsa -out ../certs/$CN/key.pem $RSA_KEY_SIZE; then
            write_log "Successfully generated RSA key pair"
        else
            write_error "Errors encountered generating RSA key pairs"
        fi
    fi
    if [ "$USE_EC" = true ]; then
        if openssl genpkey -algorithm EC -pkeyopt ec_paramgen_curve:$EC_CURVE -out ../certs/$CN/key.pem; then
            write_log "Successfully generated EC key pair"
        else
            write_error "Errors encountered generating EC key pairs"
        fi
    fi
else
    write_log "Skipping key generation, using provided key"

fi
#Generate the csr
if [[ -f ../certs/$CN/key.pem ]]; then
    if $OPENSSL_BINARY req -new -key ../certs/$CN/key.pem -out ../certs/$CN/csr.csr -config csr.conf; then
        write_log "Successfully generated csr"

        # generate a text file with the csr output for visual inspection
        if $OPENSSL_BINARY req -in ../certs/$CN/csr.csr --noout --text > ../certs/$CN/csr.txt; then
            write_log "Successfully generated csr text output"
        else
            write_error "Errors encountered when generating csr text output"
        fi
    else
        write_error "errors encountered when generating csr"
    fi
else
    write_error "Error: no key was provided, EC or RSA, check config file and select which algorithm to use."

fi

write_log "----SCRIPT FINISHED---"
