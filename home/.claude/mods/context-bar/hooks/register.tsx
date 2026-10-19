import { atom, read, update } from 'claude-code'
import type { EngineInterface, Register } from 'claude-code'

import type { Segment, Snapshot } from '../types'

const snapshot = atom({ plugin: 'context-bar', key: 'snapshot' } as const, null)
const isShown = atom({ plugin: 'context-bar', key: 'isShown' } as const, true)

/** Splits `width` cells across the segments by tokens, largest remainder first, so they sum exactly. */
export const cells = (segments: readonly Segment[], maxTokens: number, width: number): number[] => {
  if (maxTokens <= 0 || width <= 0) return segments.map(() => 0)
  const exact = segments.map(s => (s.tokens / maxTokens) * width)
  const out = exact.map(Math.floor)
  let left = Math.min(width, Math.round(exact.reduce((a, b) => a + b, 0))) - out.reduce((a, b) => a + b, 0)
  const order = exact.map((x, i) => [x - Math.floor(x), i] as const).sort((a, b) => b[0] - a[0])
  for (const [, i] of order) {
    if (left <= 0) break
    out[i] = (out[i] ?? 0) + 1
    left -= 1
  }

  return out
}

const short = (n: number) => (n >= 1000 ? `${Math.round(n / 1000)}k` : `${n}`)

/** Reads the breakdown into the snapshot; answers why it could not, or null when it did. */
const refresh = async ($: EngineInterface): Promise<string | null> => {
  let usage
  try {
    usage = await $.session.usage({ breakdown: 'summary' })
  } catch (err) {
    return `usage failed: ${err instanceof Error ? err.message : String(err)}`
  }
  const b = usage.context.breakdown
  if (!b) return 'the engine returned no breakdown'
  const segments: Segment[] = []
  for (const c of b.categories) {
    if (c.kind === 'deferred' || c.tokens <= 0) continue
    segments.push({ name: c.name, color: c.color, tokens: c.tokens, kind: c.kind })
  }
  const next: Snapshot = { segments, totalTokens: b.totalTokens, maxTokens: b.rawMaxTokens, percentage: b.percentage }
  await update($, snapshot, () => next)

  return null
}

export const register: Register = on => {
  on('session.start', async ($, e, next) => {
    await $.command.register({ name: 'context-bar', description: 'Show or hide the context window bar above the prompt' })
    void refresh($)

    return next(e)
  })

  on('session.measure', async ($, e, next) => {
    if (await read($, isShown)) await refresh($)

    return next(e)
  })

  on('command.run', { command: 'context-bar' }, async $ => {
    const shown = !(await read($, isShown))
    await update($, isShown, () => shown)
    if (!shown) return { text: 'Context bar hidden.' }
    const problem = await refresh($)

    return { text: problem ? `Context bar shown, but not drawn: ${problem}` : 'Context bar shown.' }
  })

  on('ui.render', { component: 'AbovePrompt' }, async ($, e, next) => {
    const snap = await read($, snapshot)
    if (e.props.hasSurvey || !snap || !(await read($, isShown))) return next(e)

    const { Box, Text } = $.ui.resolve(e)
    const width = Math.max(10, e.props.bodyColumns)
    const widths = cells(snap.segments, snap.maxTokens, width)
    const used = snap.segments.filter(s => s.kind === 'used')

    return (
      <Box flexDirection="column">
        <Box>
          {snap.segments.map((s, i) => (
            <Text color={s.color}>{(s.kind === 'used' ? '█' : '░').repeat(widths[i] ?? 0)}</Text>
          ))}
        </Box>
        <Box flexWrap="wrap">
          <Text dimColor>
            {snap.percentage}% · {short(snap.totalTokens)}/{short(snap.maxTokens)}{'  '}
          </Text>
          {used.map(s => (
            <Text>
              <Text color={s.color}>■</Text>
              <Text dimColor>
                {' '}
                {s.name} {short(s.tokens)}{'  '}
              </Text>
            </Text>
          ))}
        </Box>
      </Box>
    )
  })
}
