import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    globals: false,
    environment: 'node',
    setupFiles: ['./src/test-setup.js'],
    testTimeout: 15000,
    hookTimeout: 15000,
  },
});
