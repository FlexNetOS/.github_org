#!/usr/bin/env node
'use strict';
/*
 * config-health-doctor.js — runtime config-health checker for Claude Code settings.
 *
 * Sibling of claude-settings-doctor.js, which lints hardcoded-home-path RESIDUE.
 * This doctor catches the failure classes that path-linter structurally cannot —
 * the gap that hid the HUT-1 dead hook wiring (ruvector not installed;
 * ~/.claude/hooks/{gitnexus,ccg,global}/* missing; `node "~/..."` quoted-tilde):
 *
 *   For every hook command + statusLine command in settings.json, find the
 *   SCRIPT TOKEN (interpreter-aware) and classify it:
 *
 *     ERROR (host-INDEPENDENT — a real bug on every host, incl. CI):
 *       - quoted-tilde literal: `node "~/..."` / `bash '~/...'`. The `~` inside
 *         quotes is never expanded by the shell, so the path is literally "~/…".
 *       - missing repo-relative script: `bash scripts/hooks/foo.sh` where the
 *         file does not exist in the repo.
 *
 *     WARN (host-DEPENDENT — legitimately absent on CI / a fresh host, advisory):
 *       - user-global file absent: `~/.claude/hooks/x.sh`, `$HOME/...`,
 *         `${CLAUDE_CONFIG_DIR:-$HOME/.claude}/...` not present on this host.
 *       - user-global binary not on PATH: `rtk`, `ruvector`, ... (a bare command
 *         name) not resolvable in $PATH.
 *
 * Exit code is TIERED: non-zero iff there is at least one ERROR-class finding.
 * WARN-class findings print but never fail the gate — that is what makes the
 * check safe to run in CI (where rtk/ruvector and ~/.claude/* never exist) and
 * on a fresh clone, while still hard-failing on the host-independent bugs.
 *
 * This script NEVER edits any file. Read-only.
 *
 * Usage:
 *   node scripts/config-health-doctor.js [--config <path>] [--repo-root <dir>]
 *                                        [--settings-local <path>] [-h|--help]
 *   --config         settings file to scan (default: .claude/settings.json)
 *   --repo-root      root used to resolve repo-relative script paths (default: .)
 *   --settings-local optional extra settings file; scanned only if it exists
 */

const fs = require('fs');
const os = require('os');
const path = require('path');

function parseArgs(argv) {
  const out = {
    config: '.claude/settings.json',
    repoRoot: '.',
    settingsLocal: null,
  };
  for (let i = 2; i < argv.length; i++) {
    const a = argv[i];
    if (a === '-h' || a === '--help') {
      out.help = true;
    } else if (a === '--config') {
      out.config = argv[++i];
    } else if (a === '--repo-root') {
      out.repoRoot = argv[++i];
    } else if (a === '--settings-local') {
      out.settingsLocal = argv[++i];
    } else {
      throw new Error(`unknown argument: ${a}`);
    }
  }
  return out;
}

const HELP = `config-health-doctor.js — runtime config-health checker for Claude Code settings.

Classifies every hook/statusLine command and reports:
  ERROR  quoted-tilde literal ("~/..."), or a missing repo-relative hook script
  WARN   user-global file/binary absent (host-dependent; advisory only)
Exit code is non-zero iff there is at least one ERROR.

Usage: node scripts/config-health-doctor.js [--config <path>] [--repo-root <dir>]
                                            [--settings-local <path>] [-h]`;

const INTERPRETERS = new Set(['node', 'bash', 'sh', 'python', 'python3', 'deno', 'bun', 'ruby', 'perl']);

// Collect every command string from settings: hooks[event][].hooks[].command + statusLine.command.
function collectCommands(settings, source) {
  const cmds = [];
  if (settings && typeof settings.hooks === 'object' && settings.hooks) {
    for (const [event, matchers] of Object.entries(settings.hooks)) {
      if (!Array.isArray(matchers)) continue;
      for (const m of matchers) {
        if (!m || !Array.isArray(m.hooks)) continue;
        for (const h of m.hooks) {
          if (h && typeof h.command === 'string') {
            cmds.push({ source: `${source} hooks.${event}`, command: h.command });
          }
        }
      }
    }
  }
  if (settings && settings.statusLine && typeof settings.statusLine.command === 'string') {
    cmds.push({ source: `${source} statusLine`, command: settings.statusLine.command });
  }
  return cmds;
}

// Find the token that names the thing actually executed (interpreter-aware).
function scriptToken(command) {
  const tokens = command.trim().split(/\s+/);
  if (tokens.length === 0) return '';
  const lead = tokens[0];
  if (INTERPRETERS.has(lead)) {
    // first non-flag argument after the interpreter
    for (let i = 1; i < tokens.length; i++) {
      if (!tokens[i].startsWith('-')) return tokens[i];
    }
    return lead; // interpreter with no script arg — treat the interpreter as the binary
  }
  return lead;
}

function stripQuotes(tok) {
  return tok.replace(/^["']/, '').replace(/["']$/, '');
}

function isUserGlobalPath(tok) {
  return /^["']?(~\/|\$HOME\b|\$\{HOME\b|\$\{CLAUDE_CONFIG_DIR)/.test(tok);
}

function isRepoRelativePath(tok) {
  const t = stripQuotes(tok);
  if (t.includes('/') === false) return false; // bare word — a binary, not a path
  if (t.startsWith('/')) return false; // absolute — not repo-relative (path-linter's domain)
  if (/^(~|\$)/.test(t)) return false; // home/env — user-global
  return true; // e.g. scripts/hooks/foo.sh, ./x.sh, tools/bin/y
}

function isBareBinary(tok) {
  const t = stripQuotes(tok);
  return !t.includes('/') && !t.startsWith('-');
}

function expandHome(tok) {
  let t = stripQuotes(tok);
  t = t.replace(/^~(?=\/)/, os.homedir());
  t = t.replace(/\$\{HOME\}|\$HOME/g, os.homedir());
  // ${CLAUDE_CONFIG_DIR:-$HOME/.claude} -> use the default branch
  t = t.replace(/\$\{CLAUDE_CONFIG_DIR:-([^}]*)\}/, (_m, def) => def.replace(/\$\{HOME\}|\$HOME/g, os.homedir()));
  return t;
}

function onPath(bin) {
  const b = stripQuotes(bin);
  const dirs = (process.env.PATH || '').split(path.delimiter).filter(Boolean);
  for (const d of dirs) {
    const p = path.join(d, b);
    try {
      fs.accessSync(p, fs.constants.X_OK);
      return true;
    } catch (_e) {
      /* keep looking */
    }
  }
  return false;
}

function classify(command, repoRoot) {
  const tok = scriptToken(command);

  // (1) quoted-tilde literal anywhere in the command — host-independent ERROR.
  if (/["']~\//.test(command)) {
    return { level: 'ERROR', kind: 'quoted-tilde', detail: `'~' inside quotes never expands: ${command}` };
  }

  // (2) repo-relative script — must exist in the repo (host-independent ERROR if missing).
  if (isRepoRelativePath(tok)) {
    const abs = path.join(repoRoot, stripQuotes(tok));
    if (!fs.existsSync(abs)) {
      return { level: 'ERROR', kind: 'missing-repo-script', detail: `repo-relative hook script not found: ${tok}` };
    }
    return { level: 'OK', kind: 'repo-script', detail: tok };
  }

  // (3) user-global path — WARN if absent (host-dependent).
  if (isUserGlobalPath(tok)) {
    const expanded = expandHome(tok);
    if (!path.isAbsolute(expanded) || !fs.existsSync(expanded)) {
      return { level: 'WARN', kind: 'user-global-file-absent', detail: `user-global hook file absent on this host: ${tok}` };
    }
    return { level: 'OK', kind: 'user-global-file', detail: tok };
  }

  // (4) bare binary — WARN if not on PATH (host-dependent).
  if (isBareBinary(tok)) {
    if (!onPath(tok)) {
      return { level: 'WARN', kind: 'binary-not-on-path', detail: `user-global binary not on PATH on this host: ${tok}` };
    }
    return { level: 'OK', kind: 'binary', detail: tok };
  }

  return { level: 'OK', kind: 'other', detail: tok };
}

function scanFile(file, repoRoot, results, { required }) {
  if (!fs.existsSync(file)) {
    if (required) {
      console.error(`config-health-doctor: ERROR: settings file not found: ${file}`);
      results.errors.push({ source: file, detail: 'settings file not found' });
    }
    return;
  }
  let settings;
  try {
    settings = JSON.parse(fs.readFileSync(file, 'utf8'));
  } catch (e) {
    console.error(`config-health-doctor: ERROR: ${file} is not valid JSON: ${e.message}`);
    results.errors.push({ source: file, detail: 'invalid JSON' });
    return;
  }
  for (const { source, command } of collectCommands(settings, path.basename(file))) {
    const r = classify(command, repoRoot);
    if (r.level === 'ERROR') {
      results.errors.push({ source, ...r });
      console.error(`ERROR [${r.kind}] (${source}): ${r.detail}`);
    } else if (r.level === 'WARN') {
      results.warns.push({ source, ...r });
      console.log(`WARN  [${r.kind}] (${source}): ${r.detail}`);
    }
  }
}

function main() {
  let args;
  try {
    args = parseArgs(process.argv);
  } catch (e) {
    console.error(`config-health-doctor: ${e.message}`);
    process.exit(2);
  }
  if (args.help) {
    console.log(HELP);
    process.exit(0);
  }

  const results = { errors: [], warns: [] };
  scanFile(args.config, args.repoRoot, results, { required: true });
  if (args.settingsLocal) {
    scanFile(args.settingsLocal, args.repoRoot, results, { required: false });
  }

  const e = results.errors.length;
  const w = results.warns.length;
  if (e === 0) {
    console.log(`config-health-doctor: OK (${args.config} — 0 ERROR, ${w} WARN${w ? ' [host-dependent, advisory]' : ''})`);
    process.exit(0);
  }
  console.error(`config-health-doctor: ${e} ERROR-class finding(s), ${w} WARN — see above.`);
  process.exit(1);
}

main();
