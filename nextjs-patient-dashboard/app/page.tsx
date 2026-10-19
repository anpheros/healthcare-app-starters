import Link from 'next/link';
import { anpheros } from '@/lib/anpheros';

export const dynamic = 'force-dynamic';

export default async function Home() {
  const { data: patients } = await anpheros.patients.list({ limit: 50 });
  return (
    <>
      <h1>Patients</h1>
      <p className="muted">{patients.length} patients in this sandbox project, read through <code>GET /v1/patients</code>.</p>
      <div className="grid">
        {patients.map((p) => (
          <Link key={p.id} href={`/patients/${p.id}`} className="card">
            <strong>{[p.given, p.family].filter(Boolean).join(' ') || 'Unnamed'}</strong>
            <div className="muted">{p.gender ?? '—'} · born {p.birth_date ?? '—'}</div>
          </Link>
        ))}
      </div>
    </>
  );
}
