FROM alpine:3.18

# Install necessary packages
RUN apk add --no-cache openssl

WORKDIR /certificates

# Environment variables with defaults
ENV SERVER=localhost \
    CERT_EXPIRY=365 \
    KEY_SIZE=4096 \
    COUNTRY=US \
    STATE=State \
    LOCALITY=City \
    ORGANIZATION=Organization \
    ORGANIZATIONAL_UNIT=IT \
    EMAIL=admin@example.com

# Script to generate certificates
COPY generate-cert.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/generate-cert.sh

ENTRYPOINT ["/usr/local/bin/generate-cert.sh"]