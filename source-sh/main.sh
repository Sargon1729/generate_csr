#!/usr/bin/env bash
#Variables
source ./config.sh
source ./logging.sh

write_log "----SCRIPT STARTED----"
################################################################################## Verifying config file
if [[ $USE_RSA = true && $USE_EC = true ]]; then
    write_error "Cannot enable both RSA and EC at the same time"
    exit 1
fi

if [[ $USE_RSA = false && $USE_EC = false ]]; then
    write_error "USE_RSA and USE_EC cannot be both set to false"
    exit 1
fi

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

if $GENERATE_KEY; then
    if [ "$USE_RSA" = true ]; then
    write_log "Generating new RSA key pair..."
        if [ $ENCRYPT_KEY = true ]; then
            $OPENSSL_BINARY genrsa -out ../certs/$CN/key.pem "-$KEY_CIPHER" $RSA_KEY_SIZE
            rc=$?
        else
            $OPENSSL_BINARY genrsa -out ../certs/$CN/key.pem $RSA_KEY_SIZE
            rc=$?
        fi
    fi

    if [ "$USE_EC" = true ]; then
        if [ $ENCRYPT_KEY = true ]; then
            openssl genpkey -algorithm EC -pkeyopt ec_paramgen_curve:$EC_CURVE -out ../certs/$CN/key.pem "-$KEY_CIPHER"
            rc=$?
        else
            openssl genpkey -algorithm EC -pkeyopt ec_paramgen_curve:$EC_CURVE -out ../certs/$CN/key.pem
            rc=$?
        fi
    fi

    if [ $rc = 0 ]; then
        write_success "Successfully generated private key"
    else
        write_error "Errors encountered when generating private key"#
        exit 1
    fi

else
    write_log "Skipping key generation, using provided key"

fi
#Generate the csr
if [[ -f ../certs/$CN/key.pem ]]; then

    if [ $ENCRYPT_KEY = true ]; then
        write_log "Encrypted key password required for CSR"
    fi

    if $OPENSSL_BINARY req -new -key ../certs/$CN/key.pem -out ../certs/$CN/csr.csr -config csr.conf; then
        write_success "Successfully generated csr"

        # generate a text file with the csr output for visual inspection
        if $OPENSSL_BINARY req -in ../certs/$CN/csr.csr --noout --text > ../certs/$CN/csr.txt; then
            write_success "Successfully generated csr text output"
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
