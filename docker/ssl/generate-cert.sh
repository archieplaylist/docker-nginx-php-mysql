#!/bin/sh
set -e

echo "Generating SSL certificate for $SERVER"

# Create config file for certificate
cat > openssl.cnf << EOF
[req]
default_bits       = $KEY_SIZE
default_md         = sha256
distinguished_name = req_distinguished_name
req_extensions     = v3_req
prompt             = no

[req_distinguished_name]
countryName            = $COUNTRY
stateOrProvinceName    = $STATE
localityName           = $LOCALITY
organizationName       = $ORGANIZATION
organizationalUnitName = $ORGANIZATIONAL_UNIT
commonName             = $SERVER
emailAddress           = $EMAIL

[v3_req]
subjectAltName = @alt_names
keyUsage = digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth

[alt_names]
DNS.1 = $SERVER
DNS.2 = www.$SERVER
EOF

# Generate private key
openssl genrsa -out server.key $KEY_SIZE

# Generate certificate signing request
openssl req -new -key server.key -out server.csr -config openssl.cnf

# Generate self-signed certificate
openssl x509 -req -days $CERT_EXPIRY -in server.csr -signkey server.key -out server.crt \
    -extensions v3_req -extfile openssl.cnf

# Generate PEM file (combined certificate and key)
cat server.crt server.key > server.pem

# Set permissions
chmod 644 server.crt server.key server.pem

echo "Certificate files generated:"
echo " - server.key: Private key"
echo " - server.crt: Certificate"
echo " - server.pem: Combined certificate and key"
echo " - server.csr: Certificate signing request (can be deleted)"

# Clean up
rm server.csr openssl.cnf

echo "SSL certificate generation completed."