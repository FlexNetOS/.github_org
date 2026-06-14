--- 01KV1B2TETN1Z93CQGPQ2XAADV ---
  topic:      decisions-lane
  importance: critical
  weight:     1.000
  created:    2026-06-13 15:34
  accessed:   2026-06-13 17:13 (x1)
  summary:    LANE TRUE VISION (traced 2026-06-13, owner: 'a lot bigger than you think'): lane is NOT just the slim port — it is the FlexNetOS estate's NETWORK PLANE (plane 5-Feature:network, Tier B). North-star (verbatim, .handoff/context/capsule.json, source ARCHITECTURE-TRUTH.md census 2026-06-12): 'lane owns network engineering/control; obscura upgrades it with stealth agent web access.' NORTH-STAR.md: 'lane+obscura give it the network and the web; kasetto+envctl give every agent its environment and its model credentials.' Network plane = lane(B, control) + obscura(C, stealth headless browser for AI agents = lane's web-access upgrade) + network_hub(D, empty registry). THE BIG UNBUILT FRONTIER = cross-machine 'lane relay' — a STANDING WALL (NEEDS-HUMAN.md 'lane relay unfinished -> cross-machine paths unreliable'; RUVECTOR-RESEARCH.md 'Network issue lane will fix blocks reliable cross-machine reach'); lane is meant to give the RuVector edge fleet (cloud->desktop->browser->P2P->ESP32) reliable trusted connectivity. lane owns workstream W2 (network) of an 8-parallel-workstream estate upgrade (W1 envctl/kasetto, W3 weave, W4 teri/shimmy, W5 Archon, W6 rusty-idd, W7 prompt_hub, W8 ruvector). DELIVERED THIS SESSION (lane PR #30, automerge): docs/VISION.md + docs/adr/ADR-0001-lane-obscura-network-seam.md (W2 draft, recommends Option B governed-egress proxy seam, mirrors weave WL-049/ADR-0002) + refreshed backlog/loop_state (Phase-7 Round A shipped via #26/#27; added Phase 8) + fixed slim ref path. REFERENCE REPOS: only slim Go source cloned locally at /home/drdave/Downloads/tmp/router-lane/slim-extract/slim-main (lane docs cited WRONG path /home/drdave/Downloads/slim-extract/slim-main — FIXED). Two reference sets: lane docs/reference/repositories.md (16 named: ngrok/cloudflared/chisel/frp/gost/mkcert/acme-lib/caddy/traefik...) + WORKSPACE-LEVEL network_hub/README.md 'Project Referances: Network tools for Native Rust Crates' (~40: pingora, iroh/dumbpipe QUIC-p2p, obscura, vercel agent-browser, ja4, rustdesk relay, hyper).
  keywords:   lane, vision, north-star, network plane, obscura, W2, seam, lane relay, reference repos
  embedding:  yes

--- 01KV1TK042SRK26TA2ZB5H300S ---
  topic:      decisions-lane
  importance: high
  weight:     1.000
  created:    2026-06-13 20:05
  accessed:   2026-06-13 20:05 (x0)
  summary:    ADR-0001 (lane↔obscura network seam) RATIFIED 2026-06-13 — owner authorized Option B (governed-egress proxy seam) via the /lane-loop 'next 5 tasks' decision. lane spawns obscura as a managed CHILD PROCESS (not a crate dep — Option A rejected), pins its egress through a lane-controlled proxy + lane CA, gates every web op deny-by-default via pure webpolicy. Shipped the MECHANISM feature-gated (obscura=[], NO new dep) + fail-closed, ahead of obscura A1 integration (the proven lane pattern: pure parts always-compiled+tested, live driver behind cargo feature — same as ACME/multi-hop). Live obscura child-spawn + daemon/MCP lane_web dispatcher DEFERRED to Phase A1. PRs #39 (webpolicy) + #40 (src/web seam). owner-gated remaining: lane relay + network_hub registry (each needs own ADR).
  keywords:   ADR-0001, lane web, obscura, seam, Option B, webpolicy, feature-gate
  embedding:  yes

