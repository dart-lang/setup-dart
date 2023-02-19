import * as system from '../src/system'
import { expect, test } from '@jest/globals'

// These unit tests are useful for testing self-contained funcationality.
// However, we get most of our testing for this action via integration testing
// from `.github/workflows/dart.yml`.

test('getPlatform', () => {
  expect(['macos', 'linux', 'windows']).toContain(system.getPlatform())
})

test('getArch', () => {
  // Note that this test behaves slightly differently when run on GitHub.
  const runnerArch = process.env['RUNNER_ARCH'];
  if (runnerArch != null) {
    expect(system.getArch()).toEqual(runnerArch);
  } else {
    expect(['x64', 'arm64']).toContain(system.getArch())
  }
})
