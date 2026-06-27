#!/usr/bin/env node
/**
 * stop hook: one gentle reminder to persist handoff after substantial work.
 * loop_limit: 1 in hooks.json — fires at most once per session end.
 */
const raw = await new Promise((r) => {
  const c = []
  process.stdin.on('data', (d) => c.push(d))
  process.stdin.on('end', () => r(Buffer.concat(c).toString('utf8')))
})

let input = {}
try {
  input = raw ? JSON.parse(raw) : {}
} catch {
  input = {}
}

// Only nudge when agent completed (not user-cancelled mid-flight if field exists)
const status = input.status ?? input.completion_status ?? 'completed'
if (status === 'cancelled' || status === 'aborted') {
  process.stdout.write(JSON.stringify({}))
  process.exit(0)
}

const msg = [
  'If this was a large multi-step task: write SessionHandoff to `.cursor/memory/handoffs/latest.md` and consider `/dream` for durable memory.',
].join(' ')

process.stdout.write(JSON.stringify({ followup_message: msg }))
process.exit(0)
