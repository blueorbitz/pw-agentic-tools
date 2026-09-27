---
name: tailscale-docker
description: Generate a Tailscale sidecar service for docker-compose
disable-model-invocation: true
---

## Tailscale docker-compose sidecar

**Leading words**: _sidecar_, _tailnet_, _state-dir_

### Step 1: Add the tailscale service

Insert a `tailscale` service block with these fields:

```yaml
services:
  tailscale:
    image: tailscale/tailscale:latest
    container_name: <project>-ts
    hostname: <host>-<project>
    restart: unless-stopped
    cap_add:
      - NET_ADMIN
      - SYS_MODULE
    volumes:
      - <project>_ts_data:/var/lib/tailscale
    environment:
      - TS_AUTHKEY=${TAILSCALE_AUTHKEY}
      - TS_STATE_DIR=/var/lib/tailscale
      - TS_USERSPACE=false
```

**Completion criterion**: The service block exists with all seven fields above, using your project/host naming convention.

### Step 2: Declare the state volume

Add the named volume at the bottom of the compose file:

```yaml
volumes:
  <project>_ts_data:
```

**Completion criterion**: Volume declared and matches the volume name used in Step 1.

### Step 3: Attach dependent services to the tailnet

For each service that should ride the tailnet, set:

```yaml
  <service>:
    network_mode: service:tailscale
    depends_on:
      - tailscale
```

**Completion criterion**: Every target service has both `network_mode: service:tailscale` and `depends_on: tailscale`.

### Step 4: Provide the auth key at runtime

Set `TAILSCALE_AUTHKEY` in your environment (`.env`, shell, or CI secret). Use a **reusable** auth key (pre-auth, ephemeral=false) so containers rejoin on restart.

**Completion criterion**: `TAILSCALE_AUTHKEY` is defined in the runtime environment and the tailscale container logs show "Logged in" on startup.

---

## Reference: Field rationale

| Field | Why |
|-------|-----|
| `cap_add: NET_ADMIN, SYS_MODULE` | Required for kernel networking (TUN device, wireguard) |
| `TS_USERSPACE=false` | Uses kernel wireguard (faster, lower CPU) — needs SYS_MODULE |
| `TS_STATE_DIR=/var/lib/tailscale` | Pins state to the mounted volume so identity persists across recreates |
| `restart: unless-stopped` | Survives host reboots; `unless-stopped` respects explicit `docker compose stop` |
| `network_mode: service:tailscale` | Shares the tailscale container's network namespace — the service gets a tailnet IP automatically |