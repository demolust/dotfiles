#!/usr/bin/env bash

# This script expects the corresponding `wgusers` group and
# the corresponding wireguard interface has been configured correctly
interface_name="wg0"

if ! ip link show "${interface_name}" 1>/dev/null 2>&1; then
 jq --unbuffered --compact-output -n --arg in "$interface_name" '{"text": "Off", "tooltip": "VPN on \($in) Off", "class": "vpn", "percentage": 0 }'
else
 jq --unbuffered --compact-output -n --arg in "$interface_name" '{"text": "On", "tooltip": "VPN on \($in) On", "class": "vpn", "percentage": 100 }'
fi

