import { test } from 'node:test'
import assert from 'node:assert/strict'
import { spawn } from 'node:child_process'
import { mkdtempSync, mkdirSync, writeFileSync, rmSync } from 'node:fs'
import { join, dirname } from 'node:path'
import { tmpdir } from 'node:os'
import { fileURLToPath } from 'node:url'

const __dirname = dirname(fileURLToPath(import.meta.url))
const hookPath = join(__dirname, '..', 'session-start-memory.mjs')

function runHook(stdinObj) {
  return new Promise((resolve, reject) => {
    const child = spawn(process.execPath, [hookPath], {
      stdio: ['pipe', 'pipe', 'pipe'],
    })
    let stdout = ''
    let stderr = ''
    child.stdout.on('data', (d) => {
      stdout += d
    })
    child.stderr.on('data', (d) => {
      stderr += d
    })
    child.on('error', reject)
    child.on('close', (code) => {
      resolve({ code, stdout, stderr })
    })
    child.stdin.end(JSON.stringify(stdinObj ?? {}))
  })
}

test('session-start: empty input returns valid JSON object', async () => {
  const { code, stdout, stderr } = await runHook({})
  assert.equal(code, 0, stderr)
  const out = JSON.parse(stdout)
  assert.equal(typeof out, 'object')
  assert.ok(out !== null)
  // May be {} or { additional_context } if global MEMORY exists
  if ('additional_context' in out) {
    assert.equal(typeof out.additional_context, 'string')
    assert.match(out.additional_context, /Session memory/)
  } else {
    assert.deepEqual(out, {})
  }
})

test('session-start: workspace with MEMORY.md injects project memory', async () => {
  const root = mkdtempSync(join(tmpdir(), 'eco-mem-'))
  try {
    const memDir = join(root, '.cursor', 'memory')
    mkdirSync(memDir, { recursive: true })
    writeFileSync(join(memDir, 'MEMORY.md'), '# Fixture Memory\n\n- topic-a\n', 'utf8')

    const { code, stdout, stderr } = await runHook({ workspace_roots: [root] })
    assert.equal(code, 0, stderr)
    const out = JSON.parse(stdout)
    assert.equal(typeof out.additional_context, 'string')
    assert.match(out.additional_context, /Fixture Memory/)
    assert.match(out.additional_context, /Project memory/)
  } finally {
    rmSync(root, { recursive: true, force: true })
  }
})

test('session-start: workspace without MEMORY still valid JSON', async () => {
  const root = mkdtempSync(join(tmpdir(), 'eco-empty-'))
  try {
    mkdirSync(join(root, '.cursor'), { recursive: true })
    const { code, stdout, stderr } = await runHook({ workspaceRoots: [root] })
    assert.equal(code, 0, stderr)
    const out = JSON.parse(stdout)
    assert.equal(typeof out, 'object')
    // Global memory alone is fine; must not include missing project path content as crash
    if (out.additional_context) {
      assert.equal(typeof out.additional_context, 'string')
    }
  } finally {
    rmSync(root, { recursive: true, force: true })
  }
})

test('session-start: invalid JSON stdin does not crash', async () => {
  const result = await new Promise((resolve, reject) => {
    const child = spawn(process.execPath, [hookPath], { stdio: ['pipe', 'pipe', 'pipe'] })
    let stdout = ''
    let stderr = ''
    child.stdout.on('data', (d) => {
      stdout += d
    })
    child.stderr.on('data', (d) => {
      stderr += d
    })
    child.on('error', reject)
    child.on('close', (code) => resolve({ code, stdout, stderr }))
    child.stdin.end('not-json{{{')
  })
  assert.equal(result.code, 0, result.stderr)
  assert.equal(typeof JSON.parse(result.stdout), 'object')
})
