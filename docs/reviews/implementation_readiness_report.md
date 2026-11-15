# Stufe 9 – Umsetzungsbereitschaft, Runde 1: chor-assistent.md

*   **Ziel:** `docs/designs/chor-assistent.md`, DetailedRange Zeilen 618–1001,
    geprüft gegen die Spezifikation in den Zeilen 1–617
*   **Prüfer:**
    *   `egm-implementation-readiness` (implementation-readiness-standard)
    *   `egm-codebase-details` (implementation-readiness-standard)
    *   `egm-style`

    Alle drei sind gelaufen, keiner ist ausgefallen.
*   **Datum:** 2026-11-15
*   **Urteil:** **Nicht bereit für die Umsetzung.** Rundenstatus: nicht sauber.

| Prüfer | Blocker | Major | Nit |
|---|---|---|---|
| egm-implementation-readiness | 7 | 23 | 7 |
| egm-codebase-details | 4 | 17 | 7 |
| egm-style | 0 | 2 | 21 |

Die Hauptursache ist bekannt. Der Implementierungsplan wurde nach den
Korrekturen am Feature-Teil in Stufe 7 nicht angepasst. Zusätzlich sind vier
Entscheidungen des Autors aus Stufe 8 offen. Mehrere Befunde lassen sich erst
korrigieren, wenn diese Entscheidungen gefallen sind.

--------------------------------------------------------------------------------

## A. Abhängig von offenen Entscheidungen des Autors

| Entscheidung | Betroffene Befunde |
|---|---|
| **E1** `ConcertEntry` behalten oder `songIDs` (Stufe 8 Z8-M1) | Cascade-Zeitpunkt beim Durchnummerieren (IR-M14, CD-M1); `renumber`-Signatur (IR-M2, CD-N1); Snapshot im Konzertmodus mit gelöschten Einträgen (IR-M18); `move(fromOffsets:)` braucht SwiftUI im Modell (CD-N2); Import baut Einträge neu auf (IR-M13) |
| **E2** Vorzeichen-Namen (Issue 10, Z8-M2) | Picker-Labels (IR-M9, CD-B1); Verhalten in Oktave 6 (IR-M10, CD-M9) |
| **E3** Apple-Account bezahlt oder kostenlos; Umfang von G9 (Z8-M3) | Ablaufwarnung fehlt (IR-B1, CD-B1); „Als Text teilen" fehlt (IR-B2, CD-B1); Entscheidungsschritt in Schritt 0 fehlt (IR-M20) |
| **E4** Export-Erinnerung und `updatedAt` (Z8-M4) | Felder und Tests in Datei 3, 11, 29 |

## B. Unabhängig von den Entscheidungen: Der Plan fehlt oder widerspricht der Spezifikation

### Blocker

*   **B-1 Wischen:** Der Plan sieht Wischen zwischen Liedern vor (Z. 884).
    Die Spezifikation sagt „keine Wischgesten". Zusätzlich ist die API falsch
    geschrieben: richtig wäre `.tabViewStyle(.page)`. Gefunden von IR-B6,
    CD-B3 und Stil N16.
*   **B-2 Bildschirmsperre:** Der Plan verteilt die Regel auf zwei Stellen
    (Z. 663–664, 886–887). Nach einem Anruf sperrt sich der Bildschirm.
    Gefunden von IR-B7 und CD-B4.
*   **B-3 Sicherung vor dem Import und Rückgängig:** Beides fehlt ganz.
    Offen sind Dateiname, Rückfrage beim Rückgängig, Zustand des Knopfs und
    Tests. Gefunden von IR-B3 und CD-B1.
*   **B-4 Ausgabegerät und Lautstärke:** Anzeige und Warnung fehlen. Gebraucht
    werden `currentRoute`, `routeChangeNotification` und KVO auf
    `outputVolume`, außerdem eine Stelle, die dafür zuständig ist. Gefunden
    von IR-B4 und CD-B1.
*   **B-5 Sprung zu einem Lied:** fehlt. Gefunden von IR-B5 und CD-B1.
*   **B-6 `note` statt `memo`:** Der Plan bricht damit den Vertrag des
    Exportformats. Gefunden von IR-M1 und CD-B2. Ein Prüfer stuft das als
    Blocker ein.

### Major: Audio

*   **Sitzung und Sampler:** `.mixWithOthers`, Modus `.default`, die
    Bank-Parameter und Velocity 127 fehlen im Plan. Gefunden von IR-M3, IR-M4
    und CD-M6.
*   **Engine nicht neu aufbaubar:** `engine` und `sampler` sind `let`. Ein
    Neuaufbau nach einem Medien-Neustart ist so nicht möglich. Gefunden von
    IR-M5 und CD-M5.
*   **`start()` aufteilen:** in `setUp()`, einmalig mit Beobachtern und SF2,
    und `ensureRunning()`, wiederholbar. Aufgerufen wird `ensureRunning()` aus
    `play` und beim Wechsel in den Vordergrund. Bisher würden sich bei jedem
    Neustart die Beobachter stapeln. Gefunden von IR-M6, CD-B1 und Stufe 8
    Z8-N2.
*   **Nebenläufigkeit:** Benachrichtigungen kommen auf einem anderen Thread
    an, und unter `SWIFT_STRICT_CONCURRENCY = complete` braucht das ein
    festes Muster, etwa `notifications(named:)` in einem `@MainActor`-Task.
    Gefunden von CD-M4.
*   **Lebenszyklus von `isPlaying` und `soundingNotes`:** ungeklärt. Offen ist
    auch, ob `preview` einen laufenden Ablauf abbricht und welche Zeile in der
    Liederliste das Neustart-Symbol zeigt. Gefunden von IR-M8, CD-N5 und
    Stufe 6 #3.
*   **Standardwerte der Einstellungen:** `@AppStorage` schreibt seine
    Standardwerte nicht. `TonePlayer` liest deshalb 0 statt 1,0. Abhilfe ist
    `register(defaults:)` beim Start. Gefunden von CD-M7.
*   **Fehler-Banner:** Im Konzertmodus wird es von der Vollbild-Ansicht
    verdeckt. Außerdem fehlt der Text. Gefunden von IR-M7 und CD-B1.

### Major: Daten, Import und Export

*   **`replaceLibrary`:** Die Spezifikation verlangt einen eigenen Kontext
    ohne Autosave und einzelnes Löschen. Der Plan benutzt stattdessen den
    Kontext der Oberfläche und `rollback()`. Gefunden von IR-M13 und CD-M3.
*   **`@Attribute(.unique)` an `Song.id`:** Wird ein Objekt gelöscht und eins
    mit derselben ID vor dem Speichern neu eingefügt, greift das
    Upsert-Verhalten von SwiftData. Das ist fragil, und genau dieser Fall
    tritt beim Re-Import und beim Rückgängig auf. Gefunden von CD-M2 und
    IR-M13.
*   **Prüfregeln:** Sie gibt es nur am Model, die Kopie im Formular und der
    Import brauchen sie aber auch. Gebraucht wird ein gemeinsamer statischer
    Validator. Außerdem lassen sich bestehende Töne nicht bearbeiten (CUJ 3).
    Gefunden von IR-M11 und CD-M15.
*   **Import-Prüfung unvollständig:** Es fehlen 5 MB, leerer Titel und die
    Fälle von `BackupError`. Gefunden von IR-M12 und CD-B1.
*   **Export:** Der Dateiname fehlt. `ShareLink` lässt sich nicht aus einem
    Knopf heraus befüllen. `FileManager.temporaryDirectory` ist keine
    statische API. Gefunden von IR-M15 und CD-M8.
*   **Einstellungen im Import:** Unklar ist, was bei fehlendem Block passiert.
    Schrittweiten und das Label „Hörprobe" fehlen. „Begrenzt übernommen" ist
    doppeldeutig. Gefunden von IR-M16 und Stil-M2.
*   **App-Start:** Wirft `ModelContainer`, gibt es keinen Fehlerweg. Gefunden
    von CD-M17.

### Major: Konzertmodus

*   **Knöpfe:** Zurück und Weiter am Rand deaktivieren und „Beenden" oben
    links platzieren. Gefunden von IR-M17.

### Major: SoundFont (Schritt 0)

*   **Tabelle:** Sie widerspricht den Quellen und der Spezifikation:
    *   Das Instrument ist Upright Piano KW.
    *   Die Größen sind gepackt angegeben, die vollständige Variante ist
        entpackt 56 MiB groß.
    *   Salamander ist ausgeschieden.
    *   Polyphone nennt selbst „public domain".

    Ein Werkzeug zum Entpacken von `.7z` wird nicht genannt. Gefunden von
    IR-M19, CD-M13 und Stil-M1.
*   **Annahmekriterien:** nur A4 statt aller C und A, „entpackt" fehlt.
    Zusätzliches Kriterium: Die Datei hat ein Preset in Bank 0 / Program 0.
    Gefunden von IR-M19, CD-M14 und CD-M6.

### Major: Projekt, Werkzeuge und Struktur

*   **Vorlagendateien:** Die Xcode-Vorlage erzeugt Dateien, die im Plan
    fehlen: `ContentView.swift`, `Preview Content`, `Assets.xcassets` am
    Wurzelpfad, ein UI-Test-Target. Es fehlen Schritte zum Löschen bzw.
    Verschieben. Gefunden von CD-M10.
*   **swift-format:** Ohne `.swift-format`-Konfiguration ist der Standard
    2 Leerzeichen Einrückung. Ohne `--strict` gibt es keinen Fehlercode.
    Gefunden von CD-M11.
*   **Abdeckungsgrenze:** Für die 90 % ist kein Befehl angegeben
    (`-enableCodeCoverage`, `xccov`). Gefunden von CD-M12.
*   **Phasen:** Es gibt keine Phasen und keine Prüfpunkte. Der Standard
    verlangt Abschnitte, die jeweils baubar und testbar sind. Gefunden von
    IR-M21 und CD-M16.
*   **Dateiliste und Tests:** Die Dateiliste ist unvollständig, und die Tests
    decken die neuen Anforderungen nicht ab. Gefunden von IR-M22 und IR-M23.

### Nits (Auswahl)

*   **Timing:** Die Zeitwerte sollen absolute Fristen
    (`ContinuousClock.sleep(until:)`) und ganze Millisekunden sein, um
    Drift zu vermeiden. Gefunden von IR-N4 und CD-N3.
*   **Sonstiges:**
    *   `.iso8601` verliert Sekundenbruchteile (IR-N5).
    *   Der Simulatorname hängt von der Xcode-Version ab (IR-N7, CD-N6).
    *   Markdown für die Lizenzen wird nicht vollständig dargestellt (IR-N2,
        CD-N7).
    *   Kein Test für einen wiederholten Ton bei Pause 0 (CD-N4).
*   **Stil:**
    *   Begriffe: „Bundle-Ziel" statt „Deployment Target", „Tipp" statt
        „Antippen", `isValid` als „Methode", „grün sein", die Zeichen „−" und
        „·" in Formeln.
    *   Unbestimmte Angaben: „Töne gültig", „stabile Folge", „gleich".
    *   Uneinheitlich: Die Überschriften der Vorlage sind englisch.

--------------------------------------------------------------------------------

## Auflösung (Runde 1)

Status: resolved, mit dem Agenten geklärt. Eine erneute Prüfung steht aus.

**Entscheidungen des Autors:**

*   **E1:** `ConcertEntry` bleibt. Die Begründung bei R1 ist angepasst, und
    die Reihenfolge beim Löschen ist festgelegt.
*   **E2:** Doppelnamen gibt es nur im Auswahlrad, festgehalten als
    Non-Goal.
*   **E3:** kostenlose Apple-ID. Die Ablaufanzeige erscheint beim App-Start
    und im Reiter „Konzerte". „Als Text teilen" ist gestrichen, als Notfall
    dient ein Bildschirmfoto.
*   **E4:** keine Export-Erinnerung, `updatedAt` ist gestrichen.

**Folgeänderungen im Feature-Teil:**

*   Der Import läuft im Haupt-Kontext mit ausgeschaltetem Autosave und
    Rollback statt in einem eigenen Kontext, damit sich die Oberfläche auf
    iOS 17 zuverlässig aktualisiert.
*   `id` ist ohne `.unique`. Die Eindeutigkeit prüft die Import-Prüfung.
*   Es gibt nur noch ein Modell für das Timing und einen Weg zur
    Wiederherstellung der Engine (Stufe 8 Z8-N1 und Z8-N2).
*   Rückgängig verwendet den Export und das Ersetzen wieder (Z8-N4).
*   Die Sprung-Liste ist neu begründet (Z8-N5).
*   Die Herkunft der Ersatz-SoundFont ist ergänzt (Z8-N6).

**Implementierungsplan:** komplett neu geschrieben.

*   8 Phasen mit Prüfpunkten, 34 Dateien und 6 Testdateien.
*   Alle Blocker und Major-Befunde aus Abschnitt B sind darin
    berücksichtigt.
*   Die Stil-Nits sind weitgehend mit erledigt: Deployment Target,
    „Antippen", ASCII-Operatoren in Formeln, eindeutige Prüfaussagen.

Der alte Stand ist gesichert unter `scratchpad/chor-assistent.before-stage9.md`.
