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

tailscaled --tun=userspace-networking -state=/tailscale/tailscaled.state &
while ! tailscale status --peers=false >/dev/null 2>&1; do sleep 1; done

tailscale up \
	--authkey "${TAILSCALE_KEY}" \
	--hostname "${TAILSCALE_HOSTNAME}" \
	--advertise-tags "${TAILSCALE_TAGS}" \
	$@

if [ "${TAILSCALE_IP}" = true ]; then
    IP_ADDRESS=$(tailscale ip -4)
    DEVICE_ID=$(curl -X GET "https://api.balena-cloud.com/v5/device?\$filter=uuid%20eq%20'${BALENA_DEVICE_UUID}'&\$select=id" -H "Content-Type: application/json" -H "Authorization: Bearer ${BALENA_API_KEY}" -s | jq -r '.d | .[] | .id')

    curl -X POST \
    "https://api.balena-cloud.com/v6/device_tag?\$filter=device/uuid%20eq%20'${BALENA_DEVICE_UUID}'" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer ${BALENA_API_KEY}" \
    --data '{
        "device": "'${DEVICE_ID}'",
        "tag_key": "TAILSCALE_IP",
        "value": "'${IP_ADDRESS}'"
    }' \
    -s

    curl -X PATCH \
    "https://api.balena-cloud.com/v6/device_tag?\$filter=device/uuid%20eq%20'${BALENA_DEVICE_UUID}'" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer ${BALENA_API_KEY}" \
    --data '{
        "tag_key": "TAILSCALE_IP",
        "value": "'${IP_ADDRESS}'"
    }'
fi

fg