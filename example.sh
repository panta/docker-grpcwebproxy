#!/bin/bash

: ${CERT_PREFIX:="demo"}
: ${BACKEND_ADDR:="127.0.0.1"}
: ${BACKEND_PORT:="8500"}
: ${BACKEND_TLS:="true"}
: ${BACKEND_TLS_CERT_PREFIX:="backend-cert"}
: ${BACKEND_TLS_CA:="backend-ca.crt"}
: ${HTTP_DEBUG_PORT:="8080"}
: ${HTTP_TLS_PORT:="8443"}


docker run -it --rm \
    -v $(pwd)/${CERT_PREFIX}.crt:/cert.crt:ro \
    -v $(pwd)/${CERT_PREFIX}.key:/cert.key:ro \
    -v $(pwd)/${BACKEND_TLS_CERT_PREFIX}.crt:/backend-cert.crt:ro \
    -v $(pwd)/${BACKEND_TLS_CERT_PREFIX}.key:/backend-cert.key:ro \
    -v $(pwd)/${BACKEND_TLS_CA}.key:/backend-ca.crt:ro \
    panta/grpcwebproxy grpcwebproxy \
        --allow_all_origins \
        --server_tls_cert_file=/cert.crt  \
        --server_tls_key_file=/cert.key \
        --server_tls_client_cert_verification=none \
        --backend_addr=${BACKEND_ADDR}:${BACKEND_PORT} \
        --backend_client_tls_cert_file=/backend-cert.crt \
        --backend_client_tls_key_file=/backend-cert.key \
        --backend_tls_ca_files=/backend-ca.crt \
        --backend_tls=${BACKEND_TLS} \
        --run_http_server --run_tls_server \
        --server_http_debug_port ${HTTP_DEBUG_PORT} \
        --server_http_tls_port ${HTTP_TLS_PORT} \
        --use_websockets
