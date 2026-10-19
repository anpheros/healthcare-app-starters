import type { Metadata } from 'next';
import './globals.css';

export const metadata: Metadata = {
  title: 'Patient dashboard · Anpheros starter',
  description: 'A patient dashboard on a FHIR R4 healthcare API (Anpheros sandbox).',
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body>
        <main>
          {children}
          <footer>
            Synthetic sandbox data. This starter shows records; it does not diagnose or give treatment advice.
            Built on the <a href="https://developers.anpheros.com/guides/?utm_source=github&utm_medium=starter&utm_content=healthcare-app-starters">Anpheros FHIR R4 API</a>.
          </footer>
        </main>
      </body>
    </html>
  );
}
