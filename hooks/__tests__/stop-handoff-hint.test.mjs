import { test } from 'node:test'
import assert from 'node:assert/strict'
import { spawn } from 'node:child_process'
import { join, dirname } from 'node:path'
import { fileURLToPath } from 'node:url'

const __dirname = dirname(fileURLToPath(import.meta.url))
const hookPath = join(__dirname, '..', 'stop-handoff-hint.mjs')

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

test('stop: completed returns followup_message string', async () => {
  const { code, stdout, stderr } = await runHook({ status: 'completed' })
  assert.equal(code, 0, stderr)
  const out = JSON.parse(stdout)
  assert.equal(typeof out.followup_message, 'string')
  assert.match(out.followup_message, /SessionHandoff/)
  assert.match(out.followup_message, /\/dream/)
})

test('stop: empty stdin defaults to followup_message', async () => {
  const { code, stdout, stderr } = await runHook({})
  assert.equal(code, 0, stderr)
  const out = JSON.parse(stdout)
  assert.equal(typeof out.followup_message, 'string')
})

test('stop: cancelled returns empty object', async () => {
  const { code, stdout, stderr } = await runHook({ status: 'cancelled' })
  assert.equal(code, 0, stderr)
  assert.deepEqual(JSON.parse(stdout), {})
})

test('stop: aborted returns empty object', async () => {
  const { code, stdout, stderr } = await runHook({ completion_status: 'aborted' })
  assert.equal(code, 0, stderr)
  assert.deepEqual(JSON.parse(stdout), {})
})
