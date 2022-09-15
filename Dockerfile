FROM alpine:3.16

RUN apk add tailscale --repository=https://dl-cdn.alpinelinux.org/alpine/edge/community
RUN apk add bash curl iptables tailscale jq

COPY init.sh /init.sh
RUN chmod +x /init.sh

ENTRYPOINT ["/init.sh"]