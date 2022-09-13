# hslatman/tailscale-balena-block

Runs a [Tailscale](https://tailscale.com/) node on a Balena device

## Setup and configuration

Use this as standalone with the button below:

[![tailscale block deploy with balena](/deploy.svg)](https://dashboard.balena-cloud.com/deploy?repoUrl=https://github.com/hslatman/tailscale-balena-block)

Or add the following service to your docker-compose.yml:

```dockerfile  
volumes:
  tailscale-state: {}

services:
  tailscale:
    image: bh.cr/hslatman/herman/tailscale-aarch64
    restart: always
    network_mode: host
    environment:
      - TAILSCALE_KEY: <YOUR_TAILSCALE_KEY>
      - TAILSCALE_IP: <BOOLEAN>
    volumes:
      - tailscale-state:/tailscale
```

You'll need to provide a valid `Auth Key` to the `tailscale` service in the `TAILSCALE_KEY` variable.
An `Auth Key` can be created in the [Tailscale Dashboard](https://login.tailscale.com/admin/settings/authkeys).

If `TAILSCALE_IP` is set to `true`, then the Tailscale IP address of the device will be visible in the balenaCloud dashboard.

## Tailscale

[Tailscale](https://tailscale.com/) is described as a secure network that just works.
It uses [WireGuard](https://www.wireguard.com/) to tunnel traffic between hosts.

## (Potential) Improvements

- [x] Provide Docker image for the block
- [ ] Be smarter when TAILSCALE_KEY is not yet set in Balena
- [ ] Provide additional configuration options
  - [ ] subnet routing
  - [ ] ...
- [ ] Expose some tags in Tailscale?
- [x] Expose some tags in Balena?
- [ ] Support kernel networking (instead of just userspace; also see [hslatman/tailscale-balena-rpi](https://github.com/hslatman/tailscale-balena-rpi))
- [ ] Some easy way for checking that Tailscale tunnel works?
- [ ] A way to refresh/reauth tailscaled state on command?
- [x] Deploy to multi-arch fleets with GitHub actions

## Legal

WireGuard is a registered trademark of Jason A. Donenfeld.
