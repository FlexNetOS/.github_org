--- 01KTZC9808WWAW6KMWQ6H835SD ---
  topic:      decisions-architecture
  importance: critical
  weight:     1.000
  created:    2026-06-12 21:16
  accessed:   2026-06-13 19:44 (x6)
  summary:    **Handoff Context Migration:** The functional contract for handoff mechanisms, derived from the comprehensive research (ADR-001), must be codified in memory as a core operational procedure. This ensures that any future agent or human can recall the necessary steps when initiating a handover sequence, linking it to task management and system stability.

**Action Taken:** The conceptual model for handoff has been crystallized into a permanent procedural template stored within the process-rules memoir.
**Next Steps Required (Manual):** The physical migration of the *design* should be tracked by creating a formal 'Design Decision' in `context/immutable/patterns` which references this memory and initiates the actual development task to implement these standards across core repos (`agent`, `atc`).
  keywords:   handoff-protocol, arch-design, process-migration
  embedding:  yes

--- 01KTZ147TDWGX0E194X4Y7WR4H ---
  topic:      decisions-architecture
  importance: high
  weight:     0.983
  created:    2026-06-12 18:01
  accessed:   2026-06-13 18:27 (x15)
  summary:    The operational context for interacting with Anthropic models (Claude) within this meta-repo requires strictly adhering to state management contracts defined by FIX-6, handoff-discipline skills, and the FlexNetOS knowledge base. Key procedural takeaways include:
1.  **Mandatory Handoff:** All session starts/ends must use `handoff-discipline` for continuity.
2.  **Verification Precedence:** Any integration with external APIs or complex tools (like git operations) MUST follow a pattern of *Recall $\to$ Manual Verification $\to$ Action*, never skipping the manual verification step, even if the system suggests it's merged/safe.
3.  **Dependency Awareness:** Be acutely aware of dependencies across services (e.g., `envctl` injecting secrets into `teri` via its seam; `meta_cli` managing all child repos).

This memory captures a critical architectural understanding for building reliable, multi-agent systems in this repository context.
  keywords:   Claude integration, handoff protocol, context state machine, system architecture
  embedding:  yes

--- 01KTGN18NNC2HP3TK2TTJ8XK4F ---
  topic:      decisions-architecture
  importance: high
  weight:     0.904
  created:    2026-06-07 04:01
  accessed:   2026-06-07 04:01 (x0)
  summary:    fastembed-rs (Anush008/fastembed-rs) writes zero lines of unsafe in its own source — verified across all 7 core files. However, it depends on `ort` (=2.0.0-rc.12), which wraps ONNX Runtime C++ via FFI and contains extensive unsafe code. For any Rust crate declaring `#![forbid(unsafe_code)]`, depending on fastembed is NOT equivalent to safe-only — the unsafe lives in ort, not fastembed itself. This distinction matters for security-sensitive projects: fastembed's own source is safe, but its binary will contain unsafe from ort.
  keywords:   fastembed, ort, unsafe, FFI, embedding, safety, prompt-hub

