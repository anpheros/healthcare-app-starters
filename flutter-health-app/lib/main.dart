// Flutter health app starter on the Anpheros FHIR R4 API (sandbox).
//
//   flutter run --dart-define=ANPHEROS_KEY=sk_test_…
//
// A sandbox key in an app is for trying things out only: it reaches the 30 synthetic patients of your sandbox
// project. A real app lets each person connect their own record with OAuth (authorization code + PKCE, built into
// anpheros_sdk), so no key ships inside the app. Guide: https://developers.anpheros.com/guides/healthcare-app-flutter
import 'package:anpheros_sdk/anpheros_sdk.dart';
import 'package:flutter/material.dart' hide Page;

const _key = String.fromEnvironment('ANPHEROS_KEY');
const _baseUrl = String.fromEnvironment('ANPHEROS_BASE_URL', defaultValue: 'https://platform.anpheros.com');

final anpheros = Anpheros(auth: AnpherosAuth.apiKey(_key), baseUrl: _baseUrl);

void main() => runApp(const HealthApp());

class HealthApp extends StatelessWidget {
  const HealthApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Health app starter',
        theme: ThemeData(colorSchemeSeed: const Color(0xFF2F5BD3), useMaterial3: true),
        darkTheme: ThemeData(colorSchemeSeed: const Color(0xFF2F5BD3), brightness: Brightness.dark, useMaterial3: true),
        home: _key.isEmpty ? const _MissingKey() : const PatientsScreen(),
      );
}

class _MissingKey extends StatelessWidget {
  const _MissingKey();

  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text('Run with --dart-define=ANPHEROS_KEY=sk_test_…\n\n'
                'Get a free sandbox key at platform.anpheros.com/dashboard', textAlign: TextAlign.center),
          ),
        ),
      );
}

class PatientsScreen extends StatelessWidget {
  const PatientsScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Patients')),
        body: FutureBuilder<Page<Patient>>(
          future: anpheros.patients.list(limit: 50),
          builder: (context, snap) {
            if (snap.hasError) return _Error(snap.error!);
            if (!snap.hasData) return const Center(child: CircularProgressIndicator());
            final patients = snap.data!.data;
            return ListView.separated(
              itemCount: patients.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final p = patients[i];
                return ListTile(
                  title: Text(_name(p)),
                  subtitle: Text('${p.gender ?? '—'} · born ${p.birthDate ?? '—'}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => PatientScreen(patient: p))),
                );
              },
            );
          },
        ),
      );
}

class PatientScreen extends StatelessWidget {
  const PatientScreen({super.key, required this.patient});
  final Patient patient;

  Future<(Page<Observation>, Page<Condition>, Page<Medication>)> _load() async => (
        await anpheros.observations.list(patient.id, category: 'laboratory', limit: 20),
        await anpheros.conditions.listConditions(patient.id),
        await anpheros.medications.listMedications(patient.id),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(_name(patient))),
        body: FutureBuilder(
          future: _load(),
          builder: (context, snap) {
            if (snap.hasError) return _Error(snap.error!);
            if (!snap.hasData) return const Center(child: CircularProgressIndicator());
            final (labs, conditions, medications) = snap.data!;
            return ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                const _Header('Conditions'),
                for (final c in conditions.data)
                  ListTile(title: Text(c.display ?? c.code), subtitle: Text('${c.code} · ${c.clinicalStatus ?? ''}')),
                if (conditions.data.isEmpty) const _Empty(),
                const _Header('Medications'),
                for (final m in medications.data)
                  ListTile(title: Text(m.display), subtitle: Text([m.code, m.dosage].whereType<String>().join(' · '))),
                if (medications.data.isEmpty) const _Empty(),
                const _Header('Lab results'),
                for (final o in labs.data)
                  ListTile(
                    title: Text(o.display ?? o.code),
                    subtitle: Text('${o.effectiveAt?.substring(0, 10) ?? ''} · LOINC ${o.code}'),
                    trailing: Text('${o.value ?? o.valueText ?? ''} ${o.unit ?? ''}'),
                  ),
                if (labs.data.isEmpty) const _Empty(),
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Synthetic sandbox data. This app shows records; it does not diagnose or give treatment advice.',
                      style: TextStyle(fontSize: 12)),
                ),
              ],
            );
          },
        ),
      );
}

String _name(Patient p) => [p.given, p.family].whereType<String>().join(' ').trim().isEmpty
    ? 'Unnamed'
    : [p.given, p.family].whereType<String>().join(' ');

class _Header extends StatelessWidget {
  const _Header(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
        child: Text(text, style: Theme.of(context).textTheme.titleMedium),
      );
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) => const ListTile(title: Text('None recorded.'));
}

class _Error extends StatelessWidget {
  const _Error(this.error);
  final Object error;

  @override
  Widget build(BuildContext context) =>
      Center(child: Padding(padding: const EdgeInsets.all(24), child: Text('Could not load: $error')));
}
