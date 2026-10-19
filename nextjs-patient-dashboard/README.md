# Next.js patient dashboard (FHIR R4, Anpheros)

A Next.js 15 App Router starter that reads a FHIR R4 healthcare API on the server: patient list, conditions,
medications, lab results, vital signs and an International Patient Summary download.

```bash
cp .env.example .env.local   # ANPHEROS_KEY=sk_test_… (free: https://platform.anpheros.com/dashboard/?utm_source=github&utm_medium=readme&utm_content=healthcare-app-starters)
npm install
npm run dev
```

| File | |
|---|---|
| `lib/anpheros.ts` | the SDK client, server-only |
| `app/page.tsx` | patients (`GET /v1/patients`) |
| `app/patients/[id]/page.tsx` | one record: conditions, medications, labs, vitals |
| `app/api/ips/[id]/route.ts` | the IPS document (`GET /fhir/R4/Patient/{id}/$summary`) |

Synthetic sandbox data; the app shows records and does not diagnose or give treatment advice.
