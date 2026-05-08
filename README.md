### A slightly less painful way to generate certificate signing requests
Generating CSRs with openssl is great as it gives you the maximum possible flexibility, but it is a pain. This script aims to automate it and make it slightly more bearable.

Normally you'd need to generate the key, configure the csr.conf file as needed and finally generate the csr.

There is both a bath and a powershell variant depending on your environment.

All you really need to do it edit the `csr.conf` file and populate the relevant fields. You don't need every single one, most of them are commented out as they're not needed, but can be easily added. Then simply run the main script. This will generate the following;


- A folder named after the `Common Name` field to put everything neatly in.
- The CSR itself if ASCII format.
- A text file with the CSR in human readable form for easy inspection.
- The private key.

You can run it as many times as you like, and the script will just keep generating a new private key each time, and consequently a new csr files. However none of the CSR fields will change until you change and save the `csr.conf` file, only the key pair.