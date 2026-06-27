#!/usr/bin/env node
/**
 * Returns exit 0 if dream consolidation is due, 1 if skip.
 * Usage: node dream-gate.mjs [project-root]
 * Env: DREAM_MIN_HOURS=24 (default), DREAM_FORCE=1 to always pass
 */
import { readFileSync, existsSync } from 'fs'
import { join, resolve } from 'path'

const root = resolve(process.argv[2] || process.cwd())
const memoryDir = join(root, '.cursor', 'memory')
const statePath = join(memoryDir, '.dream-state.json')
const minHours = Number(process.env.DREAM_MIN_HOURS || 24)

if (process.env.DREAM_FORCE === '1') {
  console.log('dream: forced')
  process.exit(0)
}

if (!existsSync(memoryDir)) {
  console.log('dream: no memory dir — bootstrap recommended')
  process.exit(0)
}

if (!existsSync(statePath)) {
  console.log('dream: never consolidated')
  process.exit(0)
}

let state
try {
  state = JSON.parse(readFileSync(statePath, 'utf8'))
} catch {
  console.log('dream: invalid state file')
  process.exit(0)
}

const last = state.lastConsolidatedAt
  ? new Date(state.lastConsolidatedAt).getTime()
  : 0
const hoursSince = (Date.now() - last) / (1000 * 60 * 60)

if (hoursSince >= minHours) {
  console.log(`dream: due (${Math.floor(hoursSince)}h since last)`)
  process.exit(0)
}

console.log(`dream: skip (${Math.floor(hoursSince)}h < ${minHours}h)`)
process.exit(1)
