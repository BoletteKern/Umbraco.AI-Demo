import { defineConfig } from '@playwright/test';

export default defineConfig({
  use: {
    baseURL: process.env.UMBRACO_BASE_URL ?? 'https://localhost:44355',
    ignoreHTTPSErrors: true,
  },
});
