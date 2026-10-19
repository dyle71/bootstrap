import { expect, test } from 'claude-code/testing'

import { cells } from '../hooks/register'

const seg = (tokens: number, kind: 'used' | 'free' | 'buffer' = 'used') => ({ name: 'x', color: 'text', tokens, kind })

test('cells fill the width exactly when the window is accounted for', async () => {
  const out = cells([seg(30_000), seg(17_000), seg(120_000, 'free'), seg(33_000, 'buffer')], 200_000, 80)
  expect(out.reduce((a, b) => a + b, 0)).toBe(80)
  expect(out[0]).toBe(12)
})

test('cells are zero for an empty window', async () => {
  expect(cells([seg(10)], 0, 40)).toEqual([0])
})

test('/context-bar toggles the bar', async ($, on) => {
  on('session.usage', () => ({ value: {
    startedAt: 0,
    rateLimits: [],
    cost: { totalUsd: 0 },
    context: {
      window: 200_000,
      breakdown: {
        categories: [
          { name: 'Messages', tokens: 50_000, color: 'purple_FOR_SUBAGENTS_ONLY', isDeferred: false, kind: 'used' },
          { name: 'Free space', tokens: 150_000, color: 'promptBorder', isDeferred: false, kind: 'free' },
        ],
        totalTokens: 50_000,
        maxTokens: 200_000,
        rawMaxTokens: 200_000,
        autocompactSource: 'auto',
        percentage: 25,
        gridRows: [],
        model: 'test',
        memoryFiles: [],
        mcpTools: [],
        agents: [],
        isAutoCompactEnabled: true,
        apiUsage: null,
      },
    },
  } }) as never)
  on('ui.render', ($, e) => h($.ui.resolve(e).Box, {}) as never)

  for (const surface of ['terminal', 'desktop'] as const) {
    await $.command.run({ command: 'context-bar', args: '' } as never)
    let ui = await $.ui.mount({ plugin: 'context-bar', surface, component: 'AbovePrompt', props: { hasSurvey: false, isWorking: false, maxRows: 10, bodyColumns: 40 } as never })
    const hidden = await ui.find({ type: 'Text', text: /25%/ })
    await ui.unmount()
    await $.command.run({ command: 'context-bar', args: '' } as never)
    ui = await $.ui.mount({ plugin: 'context-bar', surface, component: 'AbovePrompt', props: { hasSurvey: false, isWorking: false, maxRows: 10, bodyColumns: 40 } as never })
    const shown = await ui.find({ type: 'Text', text: /25%/ })
    await ui.unmount()
    expect(hidden === undefined || hidden === null).toBe(true)
    expect(shown).toBeDefined()
  }
})
