#!/bin/bash

CRED=$1
PORT="$(jot -r 1 1024 65535)"

if [ -z "${CRED}" ]
then
    echo "Usage: . kcopy username@shostname"
    echo "or"
    echo "Usage: source kcopy username@shostname"
else
    if [ "$(/usr/bin/scp "${CRED}":~/.kube/config ~/.kube/config-"${CRED}")" -eq 0 ]
    then
        echo "Copied remote KUBECONFIG..."
    else
        echo "Error: Unable to copy remove KUBECONFIG. Exiting..."
        exit 1
    fi

    echo "Setting up proxy..."
    if [ "$(/usr/bin/ssh -D "${PORT}" -f "${CRED}" -N)" -eq 0 ]
    then
        export KUBECONFIG=~/.kube/config-"${CRED}"
        export HTTPS_PROXY=socks5://127.0.0.1:"${PORT}"
        export HTTP_PROXY=socks5://127.0.0.1:"${PORT}"
        echo "Proxy successfully setup..."
    else
        echo "Error: Unable to setup SOCKS Proxy. Exiting..."
        exit 1
    fi
fi
