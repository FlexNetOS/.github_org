--- 01KV1B2MRRHBBE7FSS979485R2 ---
  topic:      context-flexnetos
  importance: medium
  weight:     1.000
  created:    2026-06-13 15:34
  accessed:   2026-06-13 15:34 (x0)
  summary:    [consolidated] P2 dispatch shipped both halves (ADR-0008 S7). runner PR FlexNetOS/flexnetos_runner#2 (p2-uds-dispatch): runner-core::wire (DispatchRequest/DispatchResponse/WireError, sign_frame/verify_frame, 'sign what you send' HMAC-SHA256 over exact spec_json bytes) + runner-dispatch UDS server (KernelInvoker seam, handle_request: parse->verify->fork-gate->route->delegate; serve/serve_once; --socket fail-closed on empty FXRUN_DISPATCH_KEY; stdin_dry_run P0 fallback). app PR FlexNetOS/flexnetos_github_app#2 (...

