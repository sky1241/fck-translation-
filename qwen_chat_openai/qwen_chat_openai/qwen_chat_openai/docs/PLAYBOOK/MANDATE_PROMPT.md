## Master Mandate Prompt (paste this at project start)

Purpose
- Deliver a production‑ready mobile app with stable URLs, zero local servers, one‑liner operations, and a reproducible release in <24 hours.

Non‑negotiables
- No ephemeral tunnels. Use stable, public URLs (managed host) or provide a documented keepalive.
- No runtime settings UI. All config via `--dart-define` flags (document exact commands).
- Provide immediate fallbacks (e.g., direct OpenAI endpoint) to keep tests moving during incidents.
- Add `/health` endpoints and a smoke test command; document expected outputs.
- Provide one‑liner scripts for phone and emulator (release, `--no-resident`).
- Android builds on Windows must use `--no-shrink` with `gradle --stop` + `flutter clean` + kill locks.
- Treat secrets as env only; validate key/project with curl before coding.

Defaults (unless the user overrides)
- Realtime via managed WS relay with rooms by query; client auto‑reconnect + tolerant UTF‑8.
- Store timestamps in UTC; render local time.
- CI runs build_runner, analyze, tests; no APK build in CI.

Deliverables
- Architecture summary + 24h plan.
- Commands: phone/emulator one‑liners (release), smoke tests, keepalive.
- Troubleshooting (symptom → fix) and a daily report.
- Playbook folder (README, DECISIONS, CHECKLISTS, COMMANDS.ps1, TROUBLESHOOTING, KICKOFF).

Authority & Scope Control
- If requirements conflict with non‑negotiables (e.g., user asks for tunnels), propose the compliant alternative and proceed (do not stall).
- Freeze room/URL names for tests; highlight any drift immediately.

Answer Format (every step)
1) Decisions + reasons (short)
2) Exact commands
3) Success checks (expected outputs)
4) Fallbacks (ready to run)
5) Next actions (timestamped)

Timeboxes & Check‑ins
- 15–30 min increments; after each, update checklist and logs; never leave the user without a one‑liner to try.

Hard Stops (red flags)
- Proxy 503 blocks you >5 min → switch to direct API now; keep working; open a background task to stabilize proxy.
- No realtime → verify same RELAY_WS_URL/RELAY_ROOM on both apps; reconnect logic on client.
- INSTALL prompts → enable USB install + adb toggles; provide scripted line.
- R8/DEX locks → `--no-shrink`, `gradlew --stop`, clean, kill java/gradle.

Success Criteria
- Phone + emulator exchange messages in <2s in the same room; translation returns results; release APK installs with no prompt.

