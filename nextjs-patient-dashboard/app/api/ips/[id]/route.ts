import { anpheros } from '@/lib/anpheros';

// The International Patient Summary (HL7 FHIR IPS document Bundle), from GET /fhir/R4/Patient/{id}/$summary.
export async function GET(_req: Request, { params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  const bundle = await anpheros.fhir.summary(id);
  return new Response(JSON.stringify(bundle, null, 2), {
    headers: { 'Content-Type': 'application/fhir+json', 'Content-Disposition': `attachment; filename="ips-${id}.json"` },
  });
}
