"""SMART App Launch starter: standalone launch (OAuth 2.0 authorization code + PKCE) and a first FHIR R4 call against
the free Anpheros sandbox. Python 3.9+, standard library only.

    ANPHEROS_CLIENT_ID=<your public client id> python app.py      # then open http://localhost:8765

Register the client in the dashboard (https://platform.anpheros.com/dashboard/): your sandbox project → OAuth
applications → New → public, redirect URI http://localhost:8765/callback.
"""
import base64
import hashlib
import html
import json
import os
import secrets
import urllib.parse
import urllib.request
from http.server import BaseHTTPRequestHandler, HTTPServer

FHIR = os.getenv("ANPHEROS_FHIR", "https://platform.anpheros.com/fhir/R4")
CLIENT_ID = os.environ.get("ANPHEROS_CLIENT_ID", "")
PORT = int(os.getenv("PORT", "8765"))
REDIRECT = f"http://localhost:{PORT}/callback"
SCOPE = "launch/patient openid fhirUser patient/Patient.r patient/Observation.rs"
SESSION: dict = {}


def get_json(url, token=None):
    req = urllib.request.Request(url, headers={"Accept": "application/fhir+json", **({"Authorization": f"Bearer {token}"} if token else {})})
    with urllib.request.urlopen(req, timeout=20) as r:
        return json.load(r)


class Handler(BaseHTTPRequestHandler):
    def send(self, body: str, status: int = 200, location: str = None):
        self.send_response(status)
        if location:
            self.send_header("Location", location)
        self.send_header("Content-Type", "text/html; charset=utf-8")
        self.end_headers()
        self.wfile.write(body.encode())

    def do_GET(self):
        url = urllib.parse.urlparse(self.path)
        if url.path == "/":
            # 1. discovery, 2. authorization request with PKCE
            cfg = get_json(f"{FHIR}/.well-known/smart-configuration")
            verifier = secrets.token_urlsafe(48)
            challenge = base64.urlsafe_b64encode(hashlib.sha256(verifier.encode()).digest()).decode().rstrip("=")
            state = secrets.token_urlsafe(16)
            SESSION.update(verifier=verifier, state=state, token_endpoint=cfg["token_endpoint"])
            q = urllib.parse.urlencode({"response_type": "code", "client_id": CLIENT_ID, "redirect_uri": REDIRECT, "scope": SCOPE,
                                        "state": state, "aud": FHIR, "code_challenge": challenge, "code_challenge_method": "S256"})
            return self.send("", 302, f"{cfg['authorization_endpoint']}?{q}")
        if url.path == "/callback":
            q = dict(urllib.parse.parse_qsl(url.query))
            if q.get("state") != SESSION.get("state") or "code" not in q:
                return self.send(f"<p>Launch failed: {html.escape(q.get('error', 'state mismatch'))}. <a href='/'>Try again</a></p>", 400)
            # 3. token: code + PKCE verifier; the response names the patient in context
            data = urllib.parse.urlencode({"grant_type": "authorization_code", "code": q["code"], "redirect_uri": REDIRECT,
                                           "client_id": CLIENT_ID, "code_verifier": SESSION["verifier"]}).encode()
            with urllib.request.urlopen(urllib.request.Request(SESSION["token_endpoint"], data=data), timeout=20) as r:
                tok = json.load(r)
            # 4. first FHIR calls
            patient = get_json(f"{FHIR}/Patient/{tok['patient']}", tok["access_token"])
            obs = get_json(f"{FHIR}/Observation?patient={tok['patient']}&_sort=-date&_count=5", tok["access_token"])
            rows = "".join(f"<li>{html.escape((e['resource'].get('code') or {}).get('text') or '?')}: "
                           f"{html.escape(str((e['resource'].get('valueQuantity') or {}).get('value', '')))}</li>" for e in obs.get("entry", []))
            name = " ".join((patient.get("name") or [{}])[0].get("given", []))
            return self.send(f"<h1>Hello {html.escape(name or 'there')}</h1><p>Patient in context: <code>{html.escape(tok['patient'])}</code></p>"
                             f"<h2>Latest observations</h2><ul>{rows or '<li>None yet</li>'}</ul>")
        return self.send("Not found", 404)


if __name__ == "__main__":
    if not CLIENT_ID:
        raise SystemExit("Set ANPHEROS_CLIENT_ID to the public client id from the dashboard.")
    print(f"Open http://localhost:{PORT}")
    HTTPServer(("localhost", PORT), Handler).serve_forever()
