#!/usr/bin/env node
/**
 * User hook: sessionStart — inject project + global memory index into agent context.
 * Runs from ~/.cursor/ (user hook). Reads workspace roots from stdin JSON.
 */
import { readFileSync, existsSync } from 'fs'
import { join } from 'path'
import { homedir } from 'os'

async function readStdin() {
  const chunks = []
  for await (const c of process.stdin) chunks.push(c)
  return Buffer.concat(chunks).toString('utf8')
}

function readMemoryFile(path) {
  if (!existsSync(path)) return null
  try {
    const text = readFileSync(path, 'utf8').trim()
    return text.length > 0 ? text : null
  } catch {
    return null
  }
}

function truncate(text, max = 8000) {
  if (text.length <= max) return text
  return text.slice(0, max) + '\n\n… [memory truncated for sessionStart hook]'
}

const raw = await readStdin()
let input = {}
try {
  input = raw ? JSON.parse(raw) : {}
} catch {
  input = {}
}

const roots =
  input.workspace_roots ||
  input.workspaceRoots ||
  (input.cwd ? [input.cwd] : []) ||
  (input.root ? [input.root] : [])

const sections = []

const globalMemory = readMemoryFile(
  join(homedir(), '.cursor', 'memory', 'MEMORY.md'),
)
if (globalMemory) {
  sections.push(
    `## Global ecosystem memory (~/.cursor/memory/MEMORY.md)\n\n${truncate(globalMemory, 4000)}`,
  )
}

for (const root of roots) {
  if (!root || typeof root !== 'string') continue
  const projectMemory = readMemoryFile(join(root, '.cursor', 'memory', 'MEMORY.md'))
  const handoff = readMemoryFile(
    join(root, '.cursor', 'memory', 'handoffs', 'latest.md'),
  )
  if (projectMemory) {
    sections.push(
      `## Project memory (${root}/.cursor/memory/MEMORY.md)\n\n${truncate(projectMemory, 4000)}`,
    )
  }
  if (handoff) {
    sections.push(
      `## Latest handoff (${root})\n\n${truncate(handoff, 3000)}`,
    )
  }
}

if (sections.length === 0) {
  process.stdout.write(JSON.stringify({}))
  process.exit(0)
}

const additional_context = [
  '# Session memory (auto-injected by ecosystem hook)',
  '',
  'Use as orientation. Prefer current codebase over stale memory. Update via `/dream` after durable changes.',
  '',
  ...sections,
].join('\n')

process.stdout.write(JSON.stringify({ additional_context }))
process.exit(0)
