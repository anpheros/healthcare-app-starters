import Link from 'next/link';
import { anpheros } from '@/lib/anpheros';

export const dynamic = 'force-dynamic';

export default async function PatientPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  const [patient, labs, vitals, conditions, medications] = await Promise.all([
    anpheros.patients.get(id),
    anpheros.observations.list(id, { category: 'laboratory', limit: 20 }),
    anpheros.observations.list(id, { category: 'vital-signs', limit: 20 }),
    anpheros.conditions.list(id, { limit: 50 }),
    anpheros.medications.list(id, { limit: 50 }),
  ]);
  const name = [patient.given, patient.family].filter(Boolean).join(' ') || 'Unnamed';
  const value = (o: (typeof labs.data)[number]) =>
    o.components.length
      ? o.components.map((c) => `${c.value}`).join('/') + ` ${o.components[0]?.unit ?? ''}`
      : `${o.value ?? o.value_text ?? ''} ${o.unit ?? ''}`;

  return (
    <>
      <p><Link href="/">← All patients</Link></p>
      <h1>{name}</h1>
      <p className="muted">{patient.gender ?? '—'} · born {patient.birth_date ?? '—'} · FHIR <code>{patient.fhir}</code></p>
      <p><a className="button" href={`/api/ips/${id}`}>Download International Patient Summary (FHIR IPS)</a></p>

      <h2>Conditions</h2>
      {conditions.data.length ? (
        <table><thead><tr><th>Condition</th><th>Code</th><th>Status</th><th>Since</th></tr></thead><tbody>
          {conditions.data.map((c) => <tr key={c.id}><td>{c.display}</td><td>{c.code}</td><td>{c.clinical_status}</td><td>{c.onset ?? '—'}</td></tr>)}
        </tbody></table>
      ) : <p className="muted">None recorded.</p>}

      <h2>Medications</h2>
      {medications.data.length ? (
        <table><thead><tr><th>Medication</th><th>ATC</th><th>Status</th><th>Dosage</th></tr></thead><tbody>
          {medications.data.map((m) => <tr key={m.id}><td>{m.display}</td><td>{m.code ?? '—'}</td><td>{m.status}</td><td>{m.dosage ?? '—'}</td></tr>)}
        </tbody></table>
      ) : <p className="muted">None recorded.</p>}

      {[['Lab results', labs.data], ['Vital signs', vitals.data]].map(([title, rows]) => (
        <section key={title as string}>
          <h2>{title as string}</h2>
          {(rows as typeof labs.data).length ? (
            <table><thead><tr><th>Date</th><th>Test</th><th>LOINC</th><th>Value</th><th>Reference</th></tr></thead><tbody>
              {(rows as typeof labs.data).map((o) => (
                <tr key={o.id}>
                  <td>{o.effective_at?.slice(0, 10)}</td><td>{o.display}</td><td>{o.code}</td><td>{value(o)}</td>
                  <td>{o.reference_range ? `${o.reference_range.low ?? ''}–${o.reference_range.high ?? ''}` : '—'}</td>
                </tr>
              ))}
            </tbody></table>
          ) : <p className="muted">None recorded.</p>}
        </section>
      ))}
    </>
  );
}
