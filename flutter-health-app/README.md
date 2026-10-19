# Flutter health app starter (FHIR R4, Anpheros)

A Flutter app (iOS, Android, web, macOS) on a FHIR R4 healthcare API: patients, conditions (ICD-10), medications
(ATC) and lab results (LOINC), with the `anpheros_sdk` package.

```bash
flutter run --dart-define=ANPHEROS_KEY=sk_test_…
```

Get a free sandbox key at the [dashboard](https://platform.anpheros.com/dashboard/?utm_source=github&utm_medium=readme&utm_content=healthcare-app-starters).
A sandbox key in an app is for trying things out only; a real app uses OAuth (authorization code + PKCE, built into
`anpheros_sdk`) so each person connects their own record. Guide:
[Healthcare app in Flutter](https://developers.anpheros.com/guides/healthcare-app-flutter?utm_source=github&utm_medium=readme&utm_content=healthcare-app-starters).

Synthetic sandbox data; the app shows records and does not diagnose or give treatment advice.
