# ChorAssistent

iOS-App für eine Person, die im Chor die Anfangstöne angibt.

*   **Lieder:** Sie werden mit ihren Anfangstönen und gescannten Noten
    gespeichert.
*   **Töne aus dem Scan:** Ein Tipp auf den Notenkopf genügt. Die App
    erkennt die Notenlinien und berechnet den Ton aus Schlüssel und
    Vorzeichen.
*   **Abspielen:** Ein Tipp spielt die Töne nacheinander mit Klavierklang
    ab, auch bei eingeschaltetem Stummschalter.
*   **Startseite:** Sie zeigt das nächste Konzert.
*   **Konzertmodus:** Er geht im dunklen Bühnen-Look eine feste Liedfolge
    mit drei großen Knöpfen durch.
*   **Gestaltung:** warm & klassisch, mit Notenpapier, Bordeaux und Gold.

Das Design steht in [docs/designs/chor-assistent.md](docs/designs/chor-assistent.md).

**Stand:** Der Code wurde auf Windows geschrieben. Gebaut und getestet wird er
erst durch GitHub Actions. Beim ersten Lauf sind Compilerfehler zu erwarten.

## Technik

SwiftUI, SwiftData, AVFoundation (`AVAudioEngine` und `AVAudioUnitSampler`
mit einer SoundFont), VisionKit (Dokumentenscanner), Swift Testing. iOS 17 oder neuer, nur iPhone. Keine
Bibliotheken von Drittanbietern.

Das Xcode-Projekt wird **nicht** eingecheckt. Es entsteht aus `project.yml`
mit [XcodeGen](https://github.com/yonaskolb/XcodeGen).

## Weg aufs iPhone ohne eigenen Mac

```text
git push ─► GitHub Actions (macOS) ─► Tests + unsignierte ChorAssistent.ipa
                                              │
              Windows-PC: Sideloadly ◄────────┘  (signiert mit deiner Apple-ID)
                         │
                         ▼
                      iPhone
```

### Einmalig einrichten

1. Ein GitHub-Repository anlegen und diesen Ordner hineinpushen. Bei einem
   privaten Repo zählen macOS-Minuten zehnfach gegen das Freikontingent. Ein
   öffentliches Repo ist kostenlos.
2. [Sideloadly](https://sideloadly.io) auf dem Windows-PC installieren. Dazu
   gehören iTunes und iCloud in der Version von der Apple-Website, nicht aus
   dem Microsoft Store. Sideloadly nennt die Voraussetzungen beim Start.
3. Am iPhone den Entwicklermodus einschalten: Einstellungen › Datenschutz &
   Sicherheit › Entwicklermodus. Der Punkt erscheint erst, nachdem einmal
   eine App per Sideloadly installiert wurde.

### Installieren und aktualisieren

1. **IPA bauen:** Jeder Push auf `main` startet den Workflow „iOS". Von Hand
   geht es unter GitHub › Actions › iOS › *Run workflow*.
2. **IPA laden:** Im fertigen Lauf das Artefakt **ChorAssistent-ipa**
   herunterladen und entpacken. Darin liegt `ChorAssistent.ipa`.
3. **Installieren:** iPhone per USB anschließen. In Sideloadly die IPA
   wählen, die Apple-ID eintragen und *Start* drücken.
4. **Entwickler vertrauen:** Beim ersten Mal am iPhone unter Einstellungen ›
   Allgemein › VPN & Geräteverwaltung dem Entwickler (deine Apple-ID)
   vertrauen.

Die Daten in der App bleiben beim erneuten Installieren erhalten, solange die
Bundle-ID gleich bleibt.

### 7-Tage-Signatur und Regel für Konzerte

Mit einer kostenlosen Apple-ID gilt die Signatur **7 Tage**. Danach startet
die App nicht mehr.

- **Neu signieren:** Sideloadly kann die App automatisch neu signieren
  („Auto-Refresh"). Dafür müssen PC und iPhone eingeschaltet und im selben
  WLAN sein. Sonst wiederholst du Schritt 3 mit derselben IPA. Ein neuer
  Build ist dafür nicht nötig.
- **Regel:** Am Vortag jedes Konzerts neu installieren bzw. aktualisieren.
- **Restdauer:** Der Reiter „Konzerte" zeigt, wie viele Tage die Signatur
  noch gilt.
- **Notfall:** Mach vor dem Konzert ein Bildschirmfoto der Konzertliste.

## SoundFont

`ChorAssistent/Resources/Piano.sf2` ist bereits enthalten:

- **Quelle:** „Upright Piano KW, small, SF2" in der Version 2019-07-03 von
  [FreePats](https://freepats.zenvoid.org/Piano/acoustic-grand-piano.html#UprightKW).
- **Lizenz:** CC0 1.0.
- **Größe:** 9,46 MB.
- **Inhalt:** ein Preset in Bank 0 / Program 0 („Upright piano KW").
- **SHA-256:** `cf2a98eb38a32c4954b4b6e2caae4112d62dd8e892eceefdd7942b0e7d01ac2f`
- **Lizenztext:** steht vollständig in `ChorAssistent/Resources/ThirdPartyLicenses.txt`.

Noch offen ist die Prüfung der Stimmung auf dem Gerät (Prüfschritt M3).

## Was der Workflow prüft

Job **„Bauen und testen"**:
- Er erzeugt das Projekt mit XcodeGen und lässt alle Unit-Tests im Simulator
  laufen.
- Er gibt den Abdeckungsbericht aus (`xccov`).
- Danach folgt `swift format lint --strict`.

Job **„Unsignierte IPA"**:
- Er baut ein Release-Archiv ohne Signatur und packt es als
  `ChorAssistent.ipa`.
- Er läuft unabhängig von den Tests. So bekommst du auch dann eine IPA, wenn
  ein Test fehlschlägt.

## Alternativ: mit eigenem Mac

```sh
brew install xcodegen
xcodegen generate
open ChorAssistent.xcodeproj   # Signing: Team „Personal Team" wählen, dann auf das iPhone ausführen

# Tests auf der Kommandozeile
xcodebuild -project ChorAssistent.xcodeproj -scheme ChorAssistent \
  -destination 'platform=iOS Simulator,name=<Simulator>' test
```

Die Prüfung von Hand auf dem iPhone (M1–M12) steht im Abschnitt
„Verification Plan" des Designs. Dazu gehören Stummschalter, Stimmung, Anruf
im Konzertmodus und Latenz.
