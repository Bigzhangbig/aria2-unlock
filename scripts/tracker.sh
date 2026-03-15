#!/usr/bin/env bash
#
# Simple BT Tracker updater for Aria2
# Integrated into aria2-unlock project reference
#

CONF_FILE=$1
RPC_MODE=$2

TRACKER_URL="https://raw.githubusercontent.com/ngosang/trackerslist/master/trackers_all.txt"

echo "Fetching trackers from ${TRACKER_URL}..."
TRACKERS=$(curl -fsSL "${TRACKER_URL}" | grep -v '^$' | tr '\n' ',' | sed 's/,$//')

if [ -z "${TRACKERS}" ]; then
    echo "Failed to fetch trackers."
    exit 1
fi

if [ -f "${CONF_FILE}" ]; then
    echo "Updating ${CONF_FILE}..."
    if grep -q "^bt-tracker=" "${CONF_FILE}"; then
        sed -i "s@^bt-tracker=.*@bt-tracker=${TRACKERS}@" "${CONF_FILE}"
    else
        echo "bt-tracker=${TRACKERS}" >> "${CONF_FILE}"
    fi
    echo "Config file updated."
fi

if [ "${RPC_MODE}" = "RPC" ]; then
    # Try to extract RPC info from config or use defaults
    RPC_PORT=$(grep "^rpc-listen-port=" "${CONF_FILE}" | cut -d= -f2)
    RPC_SECRET=$(grep "^rpc-secret=" "${CONF_FILE}" | cut -d= -f2)
    : ${RPC_PORT:=6800}
    
    echo "Notifying Aria2 via RPC..."
    if [ -n "${RPC_SECRET}" ]; then
        PAYLOAD='{"jsonrpc":"2.0","method":"aria2.changeGlobalOption","id":"updater","params":["token:'${RPC_SECRET}'",{"bt-tracker":"'${TRACKERS}'"}]}'
    else
        PAYLOAD='{"jsonrpc":"2.0","method":"aria2.changeGlobalOption","id":"updater","params":[{"bt-tracker":"'${TRACKERS}'"}]}'
    fi
    
    curl -fsSd "${PAYLOAD}" "http://localhost:${RPC_PORT}/jsonrpc"
    echo "RPC notification sent."
fi
