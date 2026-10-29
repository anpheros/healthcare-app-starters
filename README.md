# Healthcare app starters: Next.js and Flutter on a FHIR R4 API

**Starter templates for health apps** built on a FHIR R4 healthcare API with patient consent. Clone one, add a free
sandbox key and you have a working app over 30 synthetic patients: patient list, conditions (ICD-10), medications
(ATC), lab results and vital signs (LOINC), and an International Patient Summary download.

| Starter | Stack | What it shows |
|---|---|---|
| [`nextjs-patient-dashboard`](nextjs-patient-dashboard) | Next.js 15 (App Router), TypeScript, `@anpheros/sdk` | a clinician-style patient dashboard; the API key stays on the server |
| [`flutter-health-app`](flutter-health-app) | Flutter (iOS, Android, web, macOS), `anpheros_sdk` | a mobile health record app: patients, conditions, medications, labs |
| [`smart-app-launch`](smart-app-launch) | Python 3, standard library | SMART App Launch (standalone, PKCE) and the first FHIR R4 call; [live demo](https://platform.anpheros.com/demo/smart-app-launch/) |

**Postman:** [`postman/anpheros-sandbox.postman_collection.json`](postman/anpheros-sandbox.postman_collection.json) — the first ten calls, ready to run with your sandbox key.

## Quick start in 2 minutes

1. [Get a free sandbox key](https://platform.anpheros.com/dashboard/?utm_source=github&utm_medium=readme&utm_content=healthcare-app-starters) (`sk_test_…`).
2. Run a starter:

**Next.js**

```bash
cd nextjs-patient-dashboard
cp .env.example .env.local   # put your sk_test_ key in it
npm install && npm run dev   # http://localhost:3000
```

**Flutter**

```bash
cd flutter-health-app
flutter run --dart-define=ANPHEROS_KEY=sk_test_…
```

## From starter to real app

- **Keys belong on servers.** The Next.js starter reads the key only in Server Components and route handlers. The
  Flutter starter takes a sandbox key for trying things out; a real app lets each person connect their own record
  with OAuth (authorization code + PKCE), which both SDKs implement, so no key ships inside the app.
- **Consent:** see the [consent web app example](https://github.com/anpheros/anpheros-sdk/tree/main/examples/consent-app-ts)
  and the [patient consent guide](https://developers.anpheros.com/guides/healthcare-api-patient-consent?utm_source=github&utm_medium=readme&utm_content=healthcare-app-starters).
- **Production** is for verified organisations with a data processing agreement; data stays in the EU.

The starters display records. They do not diagnose or give treatment advice, and neither should an app built from
them without the regulatory work that requires.

## Guides

[Build a healthcare app](https://developers.anpheros.com/guides/build-a-healthcare-app?utm_source=github&utm_medium=readme&utm_content=healthcare-app-starters) ·
[Healthcare app in Flutter](https://developers.anpheros.com/guides/healthcare-app-flutter?utm_source=github&utm_medium=readme&utm_content=healthcare-app-starters) ·
[Healthcare API in TypeScript](https://developers.anpheros.com/guides/healthcare-api-typescript?utm_source=github&utm_medium=readme&utm_content=healthcare-app-starters) ·
[Medical app backend](https://developers.anpheros.com/guides/medical-app-backend?utm_source=github&utm_medium=readme&utm_content=healthcare-app-starters)

Apache-2.0 · [anpheros.com](https://anpheros.com/?utm_source=github&utm_medium=readme&utm_content=healthcare-app-starters)
