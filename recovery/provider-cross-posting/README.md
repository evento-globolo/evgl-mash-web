# Recovered MASH integration workspace

This directory preserves the exact credential-clean MASH delta recovered from the 55-day ChatGPT work-reconciliation corpus. The archived repository was renamed to `evgl-mash-web`; current `main` has later cross-client coordination work, so the recovered snapshot is namespaced to avoid replacing it.

Source branch: `agent/provider-cross-posting`
Original archived commit: `73d3da807bc5e7d8ec805f49ac2f76841d0b6bd4`
Original `src/main.rs` SHA-256: `78958a6a48831e495b2e5bf61f002b769bdaf348df0925e373e1bd3bf14d8496`
Excluded source space: `dancing-dragons`

The large Rust server is stored as ordered base64 fragments under `snapshot/src/main.rs.b64.part-*`. Reconstruct it with `snapshot/restore-main.sh`, then verify it against `snapshot/src/main.rs.sha256`.
