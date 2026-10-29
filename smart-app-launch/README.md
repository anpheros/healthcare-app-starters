# SMART App Launch starter (standalone, PKCE) on a FHIR R4 sandbox

The smallest complete SMART on FHIR app: discovery, authorization code with PKCE, token with the patient in context,
then the first FHIR R4 calls. One Python file, standard library only.

**Try it without code first:** [live SMART App Launch demo](https://platform.anpheros.com/demo/smart-app-launch/) shows
every request and response.

## Run it in 5 minutes

1. [Get a free sandbox](https://platform.anpheros.com/dashboard/?src=github-smart-app-launch) (30 synthetic patients, no card).
2. In your sandbox project → **OAuth applications** → **New**: type **public**, redirect URI `http://localhost:8765/callback`.
3. Run:

```bash
ANPHEROS_CLIENT_ID=<your client id> python app.py
```

4. Open http://localhost:8765, sign in, create a test record, allow access. You land on a page with the patient in
   context and their latest observations.

## What happens

| Step | Request | Spec |
|---|---|---|
| Discovery | `GET /fhir/R4/.well-known/smart-configuration` | SMART App Launch 2.x |
| Authorize | redirect to `authorization_endpoint` with `code_challenge` (S256), `scope`, `aud` | OAuth 2.0 + PKCE |
| Token | `POST token_endpoint` with the code and `code_verifier` → `access_token`, `patient` | SMART |
| FHIR | `GET /fhir/R4/Patient/{id}`, `GET /fhir/R4/Observation?patient=…` | FHIR R4 |

Only standalone launch: the platform is not an EHR, so there is no EHR launch context. Sandbox data is synthetic;
never put real health information in it.

More: [SMART App Launch, explained](https://anpheros.com/guides/smart-app-launch-explained) ·
[Postman collection](../postman/anpheros-sandbox.postman_collection.json)
