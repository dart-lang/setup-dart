import * as system from '../src/system'
import { expect, test } from '@jest/globals'

test('getPlatform', () => {
  expect(['macos', 'linux', 'windows']).toContain(system.getPlatform())
})

test('getArch', () => {
  expect(['x64', 'arm64']).toContain(system.getArch())
})
