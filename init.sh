#!/usr/bin/env bash
# This init file was inspired by https://github.com/kazazes/balena-tailscale/blob/master/init
# and https://github.com/klutchell/balena-wireguard/blob/152b37e3a080102925c61ec8863851fe24f54c9f/insmod.sh

set -me

# if lsmod | grep wireguard >/dev/null 2>&1
# then
#     echo -n "wireguard version: "
#     cat /sys/module/wireguard/version
# else
#     echo "modprobe udp_tunnel..."
#     modprobe udp_tunnel

#     echo "modprobe ip6_udp_tunnel..."
#     modprobe ip6_udp_tunnel

#     modpath="/wireguard/wireguard.ko"

#     echo "modinfo wireguard..."
#     modinfo "${modpath}"

#     echo "insmod wireguard..."
#     if ! insmod "${modpath}"
#     then
#         dmesg | grep wireguard
#     fi
# fi

if [ -z "${TAILSCALE_KEY}" ]; then
    echo "Missing TAILSCALE_KEY env variable."
    exit 1
fi

if [ -z "${TAILSCALE_HOSTNAME}" ]; then
    export TAILSCALE_HOSTNAME=${BALENA_DEVICE_NAME_AT_INIT}
fi

# if [ -z "${TAILSCALE_TAGS}" ]; then
#     export TAILSCALE_TAGS="tag:docker,tag:balena"
# fi

tailscaled --tun=userspace-networking -state=/tailscale/tailscaled.state &
sleep 5
tailscale up -authkey "${TAILSCALE_KEY}" -hostname "${TAILSCALE_HOSTNAME}" $@

fg