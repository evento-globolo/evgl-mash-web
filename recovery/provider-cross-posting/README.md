# Recovered MASH integration workspace

This directory preserves the exact credential-clean MASH delta recovered from the 55-day ChatGPT work-reconciliation corpus. The archived repository was renamed to `evgl-mash-web`; current `main` has later cross-client coordination work, so the recovered snapshot is namespaced to avoid replacing it.

Source branch: `agent/provider-cross-posting`
Original archived commit: `73d3da807bc5e7d8ec805f49ac2f76841d0b6bd4`
Original `src/main.rs` SHA-256: `78958a6a48831e495b2e5bf61f002b769bdaf348df0925e373e1bd3bf14d8496`
Excluded source space: `dancing-dragons`

## Recovery status

The archived source payload is incomplete and must not be promoted into the live
application. The only `main.rs.b64.part-*` fragment ends mid-stream, the
alternative `main.rs.gz.b64` payload fails gzip integrity validation, and neither
can reproduce the recorded SHA-256. `snapshot/restore-main.sh` is retained only
as forensic evidence of the original recovery procedure; it is expected to fail
closed at the checksum step.

The archived design also implements a local password database and locally minted
API bearer tokens. Those mechanisms conflict with the current organization-wide
Shared Auth boundary. A future live port must use a registered Evento Globolo
client, exact issuer/audience/redirect validation, the supported Shared Auth
guard or client contract, delegated API tokens, and product-owned workspace
authorization. The credential-free provider and job UX remains useful design
input, but this snapshot is not executable or deployable source.
