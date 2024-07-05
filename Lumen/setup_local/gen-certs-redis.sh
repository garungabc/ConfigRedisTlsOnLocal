#!/bin/bash

# Generate some test certificates which are used by the regression test suite:
#
#   setup_local/certs/redis/ca.{crt,key}          Self signed CA certificate.
#   setup_local/certs/redis/redis.{crt,key}       A certificate with no key usage/policy restrictions.
#   setup_local/certs/redis/client.{crt,key}      A certificate restricted for SSL client usage.
#   setup_local/certs/redis/server.{crt,key}      A certificate restricted for SSL server usage.
#   setup_local/certs/redis/redis.dh              DH Params file.

generate_cert() {
    local name=$1
    local cn="$2"
    local opts="$3"

    local keyfile=setup_local/certs/redis/${name}.key
    local certfile=setup_local/certs/redis/${name}.crt

    [ -f $keyfile ] || openssl genrsa -out $keyfile 2048
    openssl req \
        -new -sha256 \
        -subj "/O=Redis Test/CN=$cn" \
        -key $keyfile | \
        openssl x509 \
            -req -sha256 \
            -CA setup_local/certs/redis/ca.crt \
            -CAkey setup_local/certs/redis/ca.key \
            -CAserial setup_local/certs/redis/ca.txt \
            -CAcreateserial \
            -days 365 \
            $opts \
            -out $certfile
}

mkdir -p setup_local/certs/redis
[ -f setup_local/certs/redis/ca.key ] || openssl genrsa -out setup_local/certs/redis/ca.key 4096
openssl req \
    -x509 -new -nodes -sha256 \
    -key setup_local/certs/redis/ca.key \
    -days 3650 \
    -subj '/O=Redis Test/CN=Certificate Authority' \
    -out setup_local/certs/redis/ca.crt

# cat > setup_local/certs/redis/openssl.cnf <<_END_
# [ server_cert ]
# keyUsage = digitalSignature, keyEncipherment
# nsCertType = server

# [ client_cert ]
# keyUsage = digitalSignature, keyEncipherment
# nsCertType = client
# _END_

# generate_cert server "Server-only" "-extfile setup_local/certs/redis/openssl.cnf -extensions server_cert"
# generate_cert client "Client-only" "-extfile setup_local/certs/redis/openssl.cnf -extensions client_cert"
generate_cert redis "Generic-cert"

# [ -f setup_local/certs/redis/redis.dh ] || openssl dhparam -out setup_local/certs/redis/redis.dh 2048
