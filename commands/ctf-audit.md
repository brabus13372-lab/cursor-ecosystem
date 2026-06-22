# CTF Web Infra Audit (Subagent)

Read-only audit for **remote chall + admin bot + OOB (DNS/HTTP)** chains — before
touching `solve.py` or spamming bot `/report`.

## Steps

1. Read `~/.cursor/skills/subagent-orchestrator/SKILL.md` — orchestrator synthesizes, does not dump raw output.
2. Read `~/.cursor/agents/ctf-web-infra-auditor.md` — follow its workflow and output format exactly.
3. Launch **Task** with:
   - `subagent_type`: `"explore"` (readonly code) + shell probes via direct curl/dig/python OR a readonly `"shell"` Task for probes only
   - `readonly`: `true`
   - `description`: e.g. "CTF infra audit DNXSS"
   - `prompt`: structured brief (see below)
4. Return the §6 report from the agent file. Main agent fixes infra/exploit **after** synthesis.

## Subagent brief (put in Task `prompt`)

- **Objective**: evidence-based infra audit — where the chall/bot/OOB chain breaks
- **Scope**: remote GET/POST probes, DNS TXT on 1.1.1.1, local index.php/bot.js/solve.py — no exploit writing
- **Inputs**: workspace path, chall URL, bot `/report`, webhook, s1/s2 domains, exploit URL, exfil success criteria
- **Deliverable**: `# Infra Audit` report (Summary, API table, DNS table, Chain status, Root causes, User next steps, Do NOT)
- **Constraints**: readonly; ≤3 bot POST per session; success = OOB exfil only

## Typical chain

```
/ctf-audit → (main fixes solve/DNS/URL) → /terminal (dry-run + one bot trigger) → /ctf-audit if still broken
```

## User context

Apply to whatever the user writes after this command. If paths/URLs are missing,
infer from workspace `solve.py --dry-run` and `PHASE*.txt` once, then audit.
