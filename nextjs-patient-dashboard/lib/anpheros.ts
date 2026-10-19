import 'server-only';
import { Anpheros, apiKey } from '@anpheros/sdk';

// One client for the whole server. API keys belong on servers: this module is never bundled for the browser.
// For an app where each person connects their own record, use OAuth instead (see the consent example in the README).
const key = process.env.ANPHEROS_KEY;
if (!key) throw new Error('Set ANPHEROS_KEY in .env.local (a sandbox key, sk_test_…). See .env.example.');

export const anpheros = new Anpheros({ auth: apiKey(key), baseUrl: process.env.ANPHEROS_BASE_URL });
