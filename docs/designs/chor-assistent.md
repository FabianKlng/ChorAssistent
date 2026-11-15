# ChorAssistent – iOS-App für Anfangstöne im Chor

*   **Autor:** Fabian Klingenchmid
*   **Status:** Proposed
*   **Datum:** 2026-11-15

--------------------------------------------------------------------------------

## Overview

ChorAssistent ist eine native iOS-App für eine Person, die einen Chor leitet
oder im Chor die Töne angibt. Die App speichert Lieder. Zu jedem Lied speichert
sie eine geordnete Liste von Notennamen (z. B. `D4, Fis4, A4`). Ein Tipp spielt
diese Töne nacheinander ab. Der Klang kommt aus einer mitgelieferten
Klavier-Klangdatei (SoundFont, also aufgenommene Klavier-Samples). Die Person,
die die App nutzt, nimmt selbst nichts auf.

Ein **Konzertmodus** hält eine feste Reihenfolge von Liedern für einen Auftritt
fest. Auf der Bühne geht man diese Liste Lied für Lied durch und spielt jeweils
die gespeicherten Töne ab, ohne in der Bibliothek suchen zu müssen.

Alle Daten liegen nur lokal auf einem iPhone. Es gibt keinen Server, kein
Konto und keine Synchronisierung.

## The Problem

Vor jedem Lied braucht der Chor seine Anfangstöne. Heute kommen sie meist von
einer Stimmgabel, einem Klavier oder einer allgemeinen Stimmgeräte-App. Daraus
entstehen drei Probleme:

1.  **Die Töne stehen nicht beim Lied.** Die Person, die die Töne angibt, muss
    sich für jedes Lied merken oder auf Papier notieren, welche Töne es braucht.
    Dann muss sie diese Töne auf einem Instrument oder in einer App einzeln
    suchen. Das kostet Zeit und führt zu Fehlern, vor allem bei Tönen mit
    Vorzeichen.
2.  **Im Konzert ist die Suche zu langsam.** Zwischen zwei Liedern bleiben nur
    Sekunden. Erst ein Lied in einer Liste suchen und dann jeden Ton einzeln
    eingeben, stört den Ablauf.
3.  **Allgemeine Stimm-Apps kennen keine Programmfolge.** Sie spielen einen Ton.
    Sie wissen aber nicht, welches Lied als Nächstes kommt.

Die vorgeschlagene Lösung: Jedes Lied wird einmal mit seinen Tönen gespeichert.
Für ein Konzert wird die Liedfolge einmal festgelegt. Auf der Bühne braucht es
dann pro Lied höchstens zwei Bedienschritte: zum nächsten Lied wechseln und die
Töne abspielen.

## Goals

*   **G1 – Liederbibliothek:** Lieder lassen sich anlegen, bearbeiten (Titel,
    Töne, Notiz) und löschen. Jedes Lied hat einen Titel und eine geordnete
    Liste von 1 bis 8 Tönen. Optional hat es eine kurze Notiz (z. B. „Tenor
    beginnt").
*   **G2 – Töne eingeben ohne Tippfehler:** Ein Ton wird über zwei
    Auswahlräder gewählt: Tonname (12 Halbtöne) und Oktave. Das Rad bietet nur
    Töne von C2 bis C6 an (in Oktave 6 nur C). Freitext gibt es nicht.
    Zusätzlich prüft die App beim Speichern Anzahl und Bereich der Töne.
*   **G3 – Töne abspielen:** Ein Tipp auf „Abspielen" spielt alle Töne des
    Lieds nacheinander in der gespeicherten Reihenfolge. Zwischen dem Tipp und
    dem ersten Ton liegen höchstens 100 ms, gemessen am eingebauten
    Lautsprecher. Tondauer (0,5–3,0 s, Standard 1,0 s) und Pause (0–1,0 s,
    Standard 0,15 s) sind global einstellbar und gelten für alle Lieder.
*   **G3a – Deutsche Notennamen:** Die App zeigt Töne in deutscher
    Schreibweise an: C Cis D Dis E F Fis G Gis A B H. Dabei ist „B" der Ton
    B♭ (MIDI 70) und „H" der Ton B (MIDI 71).
*   **G4 – Hörbar trotz Stummschalter:** Die Töne erklingen auch dann, wenn
    der Stummschalter des iPhones aktiv ist.
*   **G5 – Konzertmodus:** Eine Konzertliste ist eine geordnete Folge von
    Liedern aus der Bibliothek. Ein Lied darf darin mehrfach vorkommen. Im
    Konzertmodus zeigt die App das aktuelle Lied groß an. Es gibt drei große
    Bedienelemente: „Abspielen", „Weiter" und „Zurück". Solange der
    Konzertmodus angezeigt wird und die App im Vordergrund ist, sperrt sich
    der Bildschirm nicht.
*   **G6 – Offline:** Die App funktioniert komplett ohne Netzwerk.
*   **G7 – Datensicherung:** Die gesamte Bibliothek mit allen Konzertlisten
    lässt sich als eine Datei exportieren und wieder importieren, z. B. über
    das Teilen-Menü in die Dateien-App oder per AirDrop. Das ist die einzige
    Absicherung, die die App selbst anbietet. Ein iCloud- oder Finder-Backup
    des iPhones enthält die Daten ebenfalls, wenn es eingeschaltet ist. Ein
    Import ersetzt nach Rückfrage die gesamte Bibliothek. Der letzte Import
    lässt sich rückgängig machen.
*   **G8 – Mehrere Konzerte:** Es lassen sich beliebig viele Konzertlisten
    gleichzeitig speichern.
*   **G10 – Noten scannen (ergänzt am 2026-11-15):** Zu jedem Lied lassen
    sich Notenseiten mit dem Dokumentenscanner von iOS einscannen. Die Seiten
    werden beim Lied gespeichert, auf der Detailseite als Vorschaubilder
    gezeigt und lassen sich im Vollbild mit Zoom ansehen. Sie gehören zur
    Sicherung (G7).
*   **G12 – Töne im Scan antippen (ergänzt am 2026-11-15):**
    *   Man tippt im Scan auf den Notenkopf einer Stimme. Die App findet das
        Notensystem um die Tipp-Stelle selbst und berechnet den Ton aus
        Position, Schlüssel und Vorzeichen.
    *   Schlüssel: Violin, Violin oktaviert, Bass. Vorzeichen: 7 ♭ bis 7 ♯.
    *   Versetzungszeichen, die nur im Takt gelten, korrigiert man mit
        ±½. Der Ton wird zur Kontrolle angespielt.
    *   Offline und kostenlos.
*   **G11 – Gestaltung „warm & klassisch“ (ergänzt am 2026-11-15):**
    *   Cremefarbener Papierhintergrund, Bordeaux und Gold, Titel in
        Serifenschrift, eigener Dunkelmodus.
    *   Der Konzertmodus ist immer dunkel („Bühne“).
    *   Eine Startseite zeigt das nächste Konzert (Konzerte haben dafür ein
        optionales Datum) und die zuletzt angelegten Lieder.
    *   Eine Lied-Detailseite zeigt Töne, Abspielknopf, Notiz und Noten.
*   **G9 – Ablaufanzeige der Signatur:** Die App wird mit einer kostenlosen
    Apple-ID installiert, die Signatur gilt 7 Tage. Die App zeigt die
    verbleibenden Tage beim App-Start und dauerhaft im Reiter „Konzerte". Bei
    weniger als 2 Tagen erscheint eine deutliche Warnung mit dem Hinweis,
    vor dem nächsten Konzert neu zu installieren.

## Non-Goals

*   **Keine eigenen Aufnahmen.** Die App nutzt kein Mikrofon und spielt keine
    vom Nutzer aufgenommenen Audiodateien ab.
*   **Kein Akkord und keine Einzelton-Knöpfe pro Stimme.** Ein Lied wird immer
    als Ganzes nacheinander abgespielt. Wer nur den Ton einer Stimme will, hört
    ihn aus der Folge heraus.
*   **Keine Mehrbenutzer-Funktion, kein Server, keine iCloud-Synchronisierung.**
    Sänger*innen haben keinen Zugriff auf die Daten.
*   **Keine Android-, Web- oder Mac-Version.**
*   **Keine vollautomatische Notenerkennung** (entschieden am 2026-11-15).
    Auf dem Gerät gibt es dafür keine brauchbare Lösung, und ein
    Cloud-Dienst wurde abgelehnt. Stattdessen gibt es eine halbautomatische
    Erkennung durch Antippen (G12).
*   **Keine Liedtexte, PDF-Importe oder Noten im Konzertmodus.** Gescannte
    Noten sieht man auf der Lied-Detailseite, nicht auf der Bühne.
*   **Kein Stimmgerät.** Die App hört nicht zu und misst nicht, ob der Chor
    richtig singt.
*   **Kein einstellbarer Kammerton.** A4 ist immer 440 Hz.
*   **Keine englische Notenschreibweise.** Die App zeigt nur deutsche
    Notennamen an.
*   **Keine b-Namen außerhalb des Auswahlrads.** Das Auswahlrad zeigt
    Doppelnamen („Cis/Des"). In Liste und Konzertmodus steht immer der
    Kreuz-Name. Ein Lied in Des-Dur zeigt dort also „Cis4".
*   **Kein Text-Export eines Konzerts und keine Export-Erinnerung.** Als
    Notfall dient ein Bildschirmfoto der Konzertliste, als Schutz vor
    Datenverlust das Geräte-Backup und der manuelle Export.
*   **Kein Zusammenführen beim Import.** Ein Import ersetzt immer alles.
*   **Keine Veröffentlichung im App Store** als Ziel dieser Version. Installiert
    wird über Xcode auf dem eigenen Gerät (siehe offene Frage zum
    Apple-Account).

## Open Questions

*   **Endgültige SoundFont-Datei:** Annahmekriterien:
    *   SF2-Format, das `AVAudioUnitSampler` laden kann
    *   entpackt höchstens 30 MB
    *   eine Lizenz, die die Weitergabe in einer App erlaubt
    *   Stimmung geprüft: alle C und A von C2 bis C6 (MIDI 36, 45, 48, 57, 60,
        69, 72, 81, 84) mit einem Stimmgerät, jeweils ±3 Cent

    Hauptkandidat ist „FreePats Upright Piano KW, small, SF2" (ein
    Kawai-Klavier, CC0, 10 MiB entpackt). Die übrigen Quellen stehen unter
    [Additional Resources](#additional-resources). Vor der Umsetzung muss der
    Autor die Lizenz in der heruntergeladenen Datei lesen.
*   **Bauen ohne eigenen Mac (geklärt am 2026-11-15):** Die
    Entwicklungsumgebung des Autors ist Windows 11. Gebaut wird deshalb auf
    GitHub Actions (macOS-Runner):
    *   XcodeGen erzeugt das Projekt aus `project.yml`.
    *   Der Workflow lässt die Tests laufen und erzeugt eine unsignierte
        `.ipa`.
    *   Sideloadly auf dem Windows-PC signiert sie mit der kostenlosen
        Apple-ID und installiert sie.
    *   Für das wöchentliche Neusignieren reicht Sideloadly mit derselben
        `.ipa`. Ein Mac wird dafür nicht gebraucht.

    Noch offen: Wird das Repository öffentlich oder privat? Bei einem
    privaten Repository zählen macOS-Minuten zehnfach gegen das
    Freikontingent.

Geklärt in der Sitzung am 2026-11-15:

*   **Schreibweise:** deutsch, B/H (G3a). Doppelnamen nur im Auswahlrad
    (Non-Goals).
*   **Kammerton:** fest 440 Hz (Non-Goal).
*   **Tondauer und Pause:** global einstellbar (G3).
*   **Import:** ersetzt alles (G7).
*   **Mehrere Konzerte:** ja (G8).
*   **Apple-Account:** kostenlose Apple-ID, Signatur 7 Tage. Regel: am Vortag
    jedes Konzerts neu installieren. Die Ablaufanzeige (G9) unterstützt das.
*   **Reihenfolge im Konzert:** `ConcertEntry` bleibt (siehe R1).
*   **Export-Erinnerung:** keine (Non-Goals).

## Critical User Journeys (CUJs)

### CUJ 1: Lied mit Anfangstönen anlegen

*   **Given:** Die App ist installiert. Die Bibliothek ist leer oder enthält
    schon Lieder.
*   **When:** Die Nutzerin oder der Nutzer tippt auf „Neues Lied", gibt
    „Abendlied" ein und wählt nacheinander D4, Fis4 und A4. Dann speichert sie
    oder er.
*   **Then:** „Abendlied" erscheint in der Bibliothek. Die Töne stehen in der
    Reihenfolge D4, Fis4, A4. Nach einem Neustart der App sind die Daten noch
    da.

### CUJ 2: Töne in der Probe abspielen

*   **Given:** „Abendlied" ist mit D4, Fis4 und A4 gespeichert. Der
    Stummschalter des iPhones ist aktiv.
*   **When:** In der Bibliothek wird „Abendlied" geöffnet und auf „Abspielen"
    getippt.
*   **Then:** D4, Fis4 und A4 erklingen hörbar nacheinander über den
    Lautsprecher. Ein zweiter Tipp während des Abspielens startet die Folge
    neu. Ein neuer Ablauf beginnt erst, wenn der alte gestoppt ist. Das kurze
    Ausklingen des Klaviers ist erlaubt.

### CUJ 3: Konzert vorbereiten

*   **Given:** Die Bibliothek enthält mindestens drei Lieder.
*   **When:** Die Nutzerin oder der Nutzer legt das Konzert
    „Weihnachtskonzert" an, fügt vier Lieder hinzu und ändert die Reihenfolge
    durch Ziehen.
*   **Then:** Die Konzertliste zeigt die vier Lieder in der neuen Reihenfolge.
    Wird ein Lied in der Bibliothek geändert, z. B. ein Ton korrigiert, gilt die
    Änderung sofort auch im Konzert.

### CUJ 4: Konzert auf der Bühne

*   **Given:** „Weihnachtskonzert" ist angelegt. Das Gerät ist offline.
*   **When:** Der Konzertmodus wird gestartet. Vor jedem Lied tippt die
    Person auf „Abspielen" und danach auf „Weiter".
*   **Then:** Die App zeigt groß das aktuelle Lied („Lied 2 von 4") und klein
    das nächste Lied. Der Bildschirm sperrt sich während des Konzerts nicht.
    Nach dem letzten Lied ist „Weiter" deaktiviert.

### CUJ 5: Daten sichern und wiederherstellen

*   **Given:** Die Bibliothek enthält Lieder und Konzerte.
*   **When:** Über „Exportieren" wird eine Datei in der Dateien-App gespeichert.
    Später wird sie auf einem neu eingerichteten iPhone über „Importieren"
    geladen.
*   **Then:** Alle Lieder, Töne und Konzertlisten sind wieder vorhanden.
    Reihenfolgen und Notizen sind unverändert.

## Technical Plan (Architecture)

### Rahmen

*   **Plattform:** iOS 17 oder neuer, iPhone. Die Untergrenze iOS 17 ergibt
    sich aus SwiftData.
*   **Sprache und UI:** Swift, SwiftUI. Keine Bibliotheken von Drittanbietern.
    Die einzige fremde Datei ist die SoundFont-Datei.
*   **Bau und Installation:**
    *   Das Projekt entsteht aus `project.yml` (XcodeGen). Ein `.xcodeproj`
        wird nicht eingecheckt.
    *   GitHub Actions (`.github/workflows/ios.yml`, `macos-15`) baut,
        testet und erzeugt eine unsignierte `.ipa`.
    *   Installiert wird mit Sideloadly vom Windows-PC.
    *   Mit eigenem Mac geht es alternativ über `xcodegen generate` und
        Xcode.
*   **Ausrichtung:** nur Hochformat.

### Komponenten und Datenfluss

```text
┌──────────────────────── SwiftUI-Oberfläche ─────────────────────────┐
│                                                                     │
│  SongListView ──► SongEditView ──► PitchPicker                      │
│                                                                     │
│  ConcertListView ──► ConcertEditView ──► ConcertPlayerView          │
│                                          (Vollbild, große Knöpfe)   │
│                                                                     │
│  SettingsView  (Tondauer, Pause, Export / Import)                   │
└───────┬───────────────────────────┬─────────────────────┬───────────┘
        │ @Query / modelContext     │ play(pitches)       │ export/import
        ▼                           ▼                     ▼
┌────────────────┐        ┌───────────────────┐   ┌──────────────────┐
│ SwiftData      │        │ TonePlayer        │   │ BackupService    │
│ Song           │        │ AVAudioSession    │   │ JSON-Datei       │
│ Concert        │        │ AVAudioEngine     │   │ (Codable-DTOs)   │
│ ConcertEntry   │        │ AVAudioUnitSampler│   │ formatVersion: 1 │
│ (SQLite lokal) │        │  + Piano.sf2      │   └──────────────────┘
└────────────────┘        └───────────────────┘
```

Die Oberfläche liest und schreibt die Daten direkt über SwiftData
(`@Query`, `modelContext`). Abspielen läuft nur über `TonePlayer`, der als ein
einziges Objekt beim App-Start erzeugt und über die SwiftUI-Umgebung
(`@Environment`) weitergegeben wird. Export und Import laufen über
`BackupService`. Nur dieser Dienst kennt das Dateiformat.

### Datenmodell (SwiftData)

| Modell | Felder | Beziehungen |
|---|---|---|
| `Song` | `id: UUID`, `title: String`, `memo: String` (die Notiz, leer erlaubt), `pitches: [Int]` (MIDI-Nummern, geordnet), `createdAt: Date` | `entries: [ConcertEntry]`, Löschregel `.cascade`, Gegenstück `ConcertEntry.song` |
| `Concert` | `id: UUID`, `name: String`, `createdAt: Date` | `entries: [ConcertEntry]`, Löschregel `.cascade`, Gegenstück `ConcertEntry.concert` |
| `ConcertEntry` | `id: UUID`, `position: Int` | `song: Song?`, `concert: Concert?` |

*   **IDs ohne Eindeutigkeits-Zwang in der Datenbank:** `id` ist ein
    einfaches Feld, nicht `@Attribute(.unique)`. Sonst würde SwiftData beim
    Import ein gelöschtes und mit derselben ID neu angelegtes Objekt
    zusammenführen. Dass die IDs eindeutig sind, prüft die Import-Prüfung.
*   **Töne als `[Int]`:** SwiftData speichert ein Array einfacher Werte als ein
    Feld. Die Reihenfolge bleibt so erhalten. Erlaubt sind 1 bis 8 Werte im
    Bereich 36 (C2) bis 84 (C6). Das deckt die Anfangstöne von Bass bis Sopran
    ab. Die Grenzen prüft die Oberfläche beim Speichern.
*   **Löschen:** Wird ein Lied gelöscht, löscht `.cascade` alle Einträge dieses
    Lieds in allen Konzerten. SwiftData entfernt diese Einträge aber erst beim
    Speichern aus den Listen der Konzerte. Deshalb baut die App **vor** dem
    Löschen für jedes betroffene Konzert die Liste der verbleibenden Einträge
    selbst auf, nummeriert sie durch, löscht dann das Lied und speichert. Vor
    dem Löschen zeigt die App an, in wie vielen Konzerten das Lied vorkommt.
*   **Positionen pflegen:** Die Reihenfolge im Konzert hängt an einem eigenen
    Modell `ConcertEntry` mit `position`-Feld und nicht an einem Array (siehe
    Alternative R1). Das ist eine Fehlerquelle. Deshalb gibt es genau **eine**
    Funktion, die Positionen schreibt:
    `Concert.renumber(orderedEntries:)`. Sie setzt `position = 0…n-1` in der
    übergebenen Reihenfolge. Jede Änderung ruft sie auf: Hinzufügen, Entfernen,
    Verschieben und Löschen eines Lieds. Gelesen wird immer über eine
    berechnete Eigenschaft `Concert.orderedEntries`. Sie sortiert nach
    `position` und dann nach `id` und filtert Einträge mit `song == nil` heraus.
    So liefert sie auch bei doppelten oder fehlenden Positionen eine stabile
    Folge. Unit-Tests prüfen nach jeder Änderung, dass die Positionen
    lückenlos und eindeutig sind.

### Notennamen

*   **Gespeichert wird nur die MIDI-Nummer.** Notennamen werden nur für die
    Anzeige berechnet, in einer einzigen Komponente `NoteName`. Sie macht aus
    einer MIDI-Nummer einen Text, z. B. 66 → „Fis4", 70 → „B4", 71 → „H4".
    Die Schreibweise ist deutsch (G3a). Weil sie nur in dieser einen
    Komponente steckt, ließe sich später eine englische Schreibweise ergänzen,
    ohne gespeicherte Daten zu ändern.
*   **Labels im Auswahlrad:** Das Auswahlrad zeigt eigene Labels, ebenfalls
    aus `NoteName`: „C", „Cis/Des", „D", „Dis/Es", „E", „F", „Fis/Ges", „G",
    „Gis/As", „A", „B (= B♭)", „H (= B)". Damit findet man auch Töne aus
    b-Tonarten und Töne aus englischen Noten ohne Umrechnen. Überall sonst
    steht der Kreuz-Name („Cis4"). Zusätzlich spielt die App jeden Ton beim
    Auswählen kurz an. Das hilft aber nur, wenn man den Zielton im Ohr hat
    oder mit einem Instrument vergleicht.
*   **Oktavzählung:** wissenschaftliche Schreibweise, C4 = MIDI 60 = das
    mittlere C. A4 = MIDI 69.
*   **Eingabe:** `PitchPicker` besteht aus zwei Auswahlrädern: Tonname mit den
    12 Halbtönen (Labels siehe oben) und Oktave 2–6. Wird Oktave 6 gewählt,
    zeigt das Tonname-Rad nur „C". Beim Auswählen spielt die App den Ton
    sofort einmal kurz an.

### Tonerzeugung (`TonePlayer`)

*   **Audio-Sitzung:** `AVAudioSession` mit der Kategorie `.playback`, dem
    Modus `.default` und der Option `.mixWithOthers`. Die Kategorie ignoriert
    den Stummschalter (G4). Die Option sorgt dafür, dass Musik anderer Apps
    nicht stoppt. Die Sitzung wird beim App-Start aktiviert.
*   **Engine:** `AVAudioEngine` mit einem `AVAudioUnitSampler`, der an den
    `mainMixerNode` angeschlossen ist. Beim Start lädt der Sampler
    `Piano.sf2` aus dem App-Bundle über
    `loadSoundBankInstrument(at: url, program: 0, bankMSB: 0x79, bankLSB: 0)`.
    0x79 ist die Standard-Bank für melodische Instrumente. Danach werden
    `prepare()` und `start()` ausgeführt. Weil die Engine schon läuft, bevor
    jemand auf „Abspielen" tippt, soll die Grenze von 100 ms bis zum ersten
    Ton erreichbar sein (G3). Geprüft wird das mit einem Zeitlupenvideo am
    eingebauten Lautsprecher (siehe Prüfplan).
*   **Abspielen:** Beim Abspielen berechnet die App aus Tönen, Tondauer und
    Pause einen Ablaufplan mit Start- und Endzeit jedes Tons (eine reine
    Funktion, ohne Audio testbar). Ein Hintergrund-Ablauf arbeitet genau
    diesen Plan ab: Er wartet bis zu jeder geplanten Zeit, startet bzw.
    stoppt den Ton und benutzt dabei die größte Anschlagstärke, also die
    größte Lautstärke. Es gibt nur dieses eine Modell für das Timing.
*   **Einstellungen (`PlaybackSettings`):** `toneDuration` (0,5–3,0 s,
    Schritt 0,1, Standard 1,0) und `gap` (0–1,0 s, Schritt 0,05, Standard
    0,15) werden mit `@AppStorage` in UserDefaults gespeichert, nicht in
    SwiftData. Neben den Reglern spielt der Knopf „Hörprobe" C4–E4–G4 mit den
    aktuellen Werten ab.
*   **Neu starten statt überlagern:** Ein neuer Aufruf von `play` bricht den
    laufenden `Task` ab, schickt `stopNote` für alle zuletzt gespielten Töne
    und beginnt von vorn (CUJ 2). `stop()` macht dasselbe, ohne neu zu starten.
    `isPlaying` ist beobachtbar, damit der Knopf während des Abspielens seinen
    Zustand anzeigen kann.
*   **Kammerton:** fest 440 Hz. `sampler.globalTuning` bleibt 0.
*   **Ein Weg zur Wiederherstellung:** `TonePlayer` hat genau eine
    Zuständigkeit „Engine läuft sicherstellen". Sie aktiviert die Sitzung und
    startet die Engine, falls sie nicht läuft. Alle Auslöser rufen sie auf:
    jedes Abspielen, die Rückkehr der App in den Vordergrund, das Ende einer
    Unterbrechung (z. B. ein Anruf) und ein Wechsel des Ausgabegeräts. Das
    Ende einer Unterbrechung meldet iOS nicht zuverlässig. Deshalb ist der
    Aufruf beim Abspielen der entscheidende. Ohne ihn bleibt die App nach
    einem Anruf stumm, und im Konzert merkt man das erst beim nächsten Lied.
*   **Neustart der Mediendienste:** Startet iOS seine Mediendienste neu, sind
    Engine und Sampler unbrauchbar. Dann baut `TonePlayer` beide neu auf, lädt
    die SoundFont neu und stellt danach wie oben sicher, dass die Engine
    läuft.
*   **Fehlerfall:** Lässt sich die SoundFont nicht laden oder die Engine nicht
    starten, zeigt die App oben auf dem Bildschirm ein Banner: „Ton nicht
    verfügbar – App neu starten". Ein stummer Knopf ist im Konzert schlimmer
    als eine Fehlermeldung.

### Konzertmodus (`ConcertPlayerView`)

*   Die Ansicht wird als Vollbild-Ansicht (`fullScreenCover`) aus
    `ConcertEditView` geöffnet. Sie hält `currentIndex` als lokalen Zustand.
    Dieser wird nicht gespeichert, und ein neues Öffnen beginnt bei Lied 1.
*   **Anzeige:** Liedtitel groß, darunter die Notennamen der Töne und die
    Notiz. Außerdem „Lied 2 von 4" und klein „Als Nächstes: …".
*   **Ausgabe:** Die Ansicht zeigt das aktuelle Ausgabegerät
    (iPhone-Lautsprecher, Kopfhörer oder Bluetooth). Ist die Medienlautstärke
    unter 30 %, zeigt sie eine Warnung.
*   **Bedienung:** drei große Knöpfe: „Zurück", „Abspielen", „Weiter".
    „Abspielen" nimmt etwa die halbe Bildschirmhöhe ein. „Zurück" und „Weiter"
    sind am ersten bzw. letzten Lied deaktiviert. Ein Wechsel des Lieds stoppt
    einen laufenden Ton. Es gibt keine Wischgesten.
*   **Sprung zu einem Lied:** Ein Tipp auf „Lied n von N" öffnet die Liste
    des Konzerts. Ein Tipp auf ein Lied springt dorthin. Gebraucht wird das,
    wenn die App mitten im Konzert beendet oder neu gestartet wurde, denn der
    Konzertmodus beginnt dann wieder bei Lied 1. „Lied n von N" steht oben,
    weit weg vom Knopf „Abspielen".
*   **Beenden:** „Beenden" steht oben links und verlangt eine Rückfrage.
*   **Bildschirm:** Es gibt genau eine Regel an einer Stelle: Die
    Bildschirmsperre ist genau dann aus, wenn der Konzertmodus angezeigt wird
    **und** die App im Vordergrund aktiv ist. Die Konzertansicht wertet die
    Regel bei jedem Wechsel von Anzeige oder App-Zustand neu aus. Nach einer
    Rückkehr aus dem Hintergrund, z. B. nach einem Anruf, ist die Sperre also
    wieder aus.
*   **Leere Konzerte:** Ein Konzert ohne Einträge lässt sich nicht im
    Konzertmodus starten. Der Knopf ist dann deaktiviert.

### Ablaufanzeige der Signatur (G9)

*   Beim App-Start liest die App einmal das Ablaufdatum ihrer Signatur aus
    der mitgelieferten Provisioning-Datei (`embedded.mobileprovision`).
*   Die verbleibenden Tage stehen dauerhaft oben im Reiter „Konzerte", z. B.
    „Signatur gültig: noch 5 Tage".
*   Bei weniger als 2 Tagen erscheint beim App-Start ein Hinweis: „Signatur
    läuft in 1 Tag ab. Vor dem nächsten Konzert neu installieren." Dieselbe
    Zeile im Reiter wird rot.
*   Lässt sich das Datum nicht lesen, z. B. bei einer anderen Art der
    Installation, entfällt die Anzeige ohne Fehler.

### Export und Import (`BackupService`)

*   **Format:** UTF-8-JSON mit dem Dateityp `.json` (`UTType.json`), damit
    kein eigener Dateityp angemeldet werden muss. Der Dateiname lautet
    `ChorAssistent-Sicherung-JJJJ-MM-TT.json`.
    ```text
    {
      "formatVersion": 1,
      "exportedAt": "<ISO-8601>",
      "settings": { "toneDuration": Double, "gap": Double },             // optional
      "songs":    [ { "id", "title", "memo", "pitches": [Int], "createdAt" } ],
      "concerts": [ { "id", "name", "createdAt", "songIDs": [UUID] } ]   // geordnet
    }
    ```
    In der Datei stehen Konzerte als geordnete Liste von Lied-IDs. Die
    `position`-Felder gibt es nur in der App-Datenbank. Beim Import werden sie
    über `renumber` neu erzeugt.
*   **Export:** Die App erzeugt die Datei in einem temporären Ordner und gibt sie
    über `ShareLink` an das Teilen-Menü weiter (Dateien-App, AirDrop).
*   **Import:** Über `fileImporter` wählt man eine Datei aus. Die App liest sie
    vollständig ein und prüft sie, bevor sie etwas ändert:
    *   Ist die Datei höchstens 5 MB groß?
    *   Ist `formatVersion` bekannt?
    *   Liegen alle Töne im Bereich 36–84, und hat jedes Lied 1–8 Töne?
    *   Hat jedes Lied einen Titel, der nicht leer ist?
    *   Gibt es zu jeder `songID` ein Lied?
    *   Sind alle IDs von Liedern und Konzerten eindeutig?

    Bei einem Fehler in der Datei bleibt die bestehende Bibliothek
    unverändert. Sonst folgt die Rückfrage. Sie nennt die Zahlen aus der Datei
    und aus der Bibliothek: „Die Datei vom 12.10.2026 enthält 24 Lieder und 3
    Konzerte. Deine aktuelle Bibliothek mit 27 Liedern und 4 Konzerten wird
    ersetzt." Nach der Bestätigung geschieht Folgendes:
    1.  Die App schreibt automatisch eine Sicherung der aktuellen Bibliothek
        in ihren Documents-Ordner. Sie hebt nur die jeweils letzte auf.
    2.  Der Import läuft im Haupt-Datenbank-Kontext. Während des Imports ist
        das automatische Speichern ausgeschaltet. So aktualisiert sich die
        Oberfläche danach zuverlässig, auch auf iOS 17. Objekte werden einzeln
        gelöscht, nicht per Batch-Delete. Gespeichert wird einmal am Ende.
    3.  Schlägt das Speichern fehl, nimmt die App alle ungespeicherten
        Änderungen zurück (Rollback). Die Bibliothek bleibt dann, wie sie
        war.

    Die Sicherung aus Schritt 1 schreibt dieselbe Funktion wie der Export.
    „Letzten Import rückgängig machen" spielt diese Sicherung über denselben
    Ersetzen-Weg wieder ein, ohne weitere Rückfrage und ohne selbst eine neue
    Sicherung anzulegen. Enthält die Datei einen Block `settings`,
    werden die Werte übernommen und auf die erlaubten Grenzen begrenzt. Fehlt
    der Block, bleiben die aktuellen Einstellungen erhalten.

### Navigation

`TabView` mit drei Reitern: **Lieder**, **Konzerte** und **Einstellungen**.
Unter Einstellungen liegen Tondauer, Pause, Export, Import und „Letzten
Import rückgängig machen".

### Risiken

| Risiko | Folge | Gegenmaßnahme |
|---|---|---|
| Signatur abgelaufen (kostenlose Apple-ID: 7 Tage) | App startet im Konzert nicht | Regel: am Vortag jedes Konzerts neu installieren; Ablaufanzeige (G9); als Notfall vorher ein Bildschirmfoto der Konzertliste machen |
| Kein Mac verfügbar | App lässt sich nicht bauen und nicht neu signieren | Bauen auf GitHub Actions, Signieren und Installieren mit Sideloadly unter Windows |
| GitHub Actions oder Sideloadly fällt aus bzw. ändert sich | Kein neuer Build bzw. keine Neusignierung | Die letzte `.ipa` lokal aufheben (Artefakte verfallen nach 30 Tagen); vor Konzerten frühzeitig neu signieren |
| SoundFont schlecht gestimmt oder Lizenz unklar | Falsche Töne bzw. rechtliches Problem | Annahmekriterien (offene Frage): alle C und A von C2 bis C6 prüfen; bei CC-BY Namensnennung unter Einstellungen › Lizenzen |
| `position`-Werte inkonsistent | Falsche Konzertfolge | Nur `renumber` schreibt Positionen; Lesen sortiert stabil; Unit-Tests |
| Engine nach Anruf, Kopfhörerwechsel oder Medien-Neustart gestoppt | Stummer Knopf im Konzert | Benachrichtigungen behandeln, Selbstheilung bei jedem Abspielen, Banner im Fehlerfall |
| Falsches Ausgabegerät oder Lautstärke zu niedrig | Chor hört Töne nicht | Anzeige des Ausgabegeräts und Lautstärke-Warnung im Konzertmodus; größte Anschlagstärke. Ein Bluetooth-Lautsprecher ist möglich, verletzt aber die Grenze von 100 ms |
| Fehler in einem jungen Framework (SwiftData) | Datenverlust oder Absturz | Einfaches Modell, manueller Export, Geräte-Backup (iCloud/Finder), automatische Sicherung vor jedem Import, Tests für Löschen und Umsortieren. Eine Export-Erinnerung gibt es bewusst nicht |
| Gültiger, aber älterer Import | Neuere Lieder gehen verloren | Rückfrage mit Zahlen; „Letzten Import rückgängig machen" |
| B/H oder b-Namen beim Übertragen verwechselt | Halbton falscher Anfangston | Doppel-Labels im Auswahlrad („Cis/Des", „B (= B♭)", „H (= B)"); Ton beim Auswählen anspielen |
| Sicherheit: manipulierte oder sehr große Importdatei | Absturz oder unsinnige Daten | Vollständige Prüfung vor jeder Änderung, höchstens 5 MB. Die App verarbeitet keine personenbezogenen Daten und hat keinen Netzwerkzugriff |
| Skalierung: große Bibliothek | Keine nennenswerte | Mehrere hundert Lieder sind unter 100 KB. 8 Töne pro Lied und der Bereich 36–84 decken übliche Chorlagen ab |

### Erweiterung vom 2026-11-15: Design und Notenscans

*   **Design-System:** `Design/Theme.swift` legt eine Palette aus
    dynamischen Farben für hell und dunkel an. Dazu kommen Serifenschrift
    und die Darstellung der Navigationsleisten. `Design/Components.swift`
    enthält die Bausteine:
    *   Karte und Abschnittstitel
    *   Ton-Chips mit umbrechendem Layout
    *   Notenlinien als Zierelement
    *   Hinweis-Karte
*   **Aufbau:** Die App hat vier Reiter: Start, Lieder, Konzerte und
    Einstellungen.
    *   Neu sind `HomeView` und `SongDetailView`.
    *   Bearbeitet wird immer in einem Sheet.
    *   `Concert.next(from:now:)` bestimmt das Konzert für die Startseite:
        das früheste mit Datum ab heute, sonst das neueste ohne Datum.
*   **Noten:** Neues Modell `ScorePage`. Es speichert `pageNumber` und
    `imageData` als JPEG mit `@Attribute(.externalStorage)` und gehört zu
    `Song.scorePages`. Wird das Lied gelöscht, werden die Seiten mit
    gelöscht (`.cascade`).
    *   Gescannt wird mit `VNDocumentCameraViewController` (VisionKit). Auf
        dem Simulator ist er nicht verfügbar.
    *   `ImageCompressor` verkleinert die längste Kante auf 2000 px und
        speichert als JPEG mit Qualität 0,7.
    *   Neue Seiten kommen ans Ende. Umsortieren gibt es nicht, deshalb
        braucht es kein Durchnummerieren.
    *   Angesehen werden die Seiten in `ScoreViewer`: Seiten blättern,
        Pinch-Zoom bis 5×, Doppeltipp schaltet den Zoom um.
    *   Für die Kamera ist `NSCameraUsageDescription` in `project.yml`
        eingetragen.
*   **Sicherung, Format 2:** Lieder enthalten `scorePages` (Base64),
    Konzerte enthalten `date`.
    *   Dateien im Format 1 bleiben lesbar.
    *   Die Importgrenze steigt von 5 MB auf 200 MB.
    *   Ohne die Scans wäre eine Sicherung bei Geräteverlust unvollständig.
*   **Töne antippen:** Die Rechenlogik (`StaffPitch`, `StaffDetector`)
    ist vom Bildteil (`StaffImageAnalyzer`) getrennt und deshalb testbar.
    *   Die Linien werden über ein Zeilenprofil dunkler Pixel gesucht. Gezählt
        werden nur Spalten links und rechts der Tipp-Stelle; der Notenkopf
        selbst zählt nicht mit.
    *   Als Notensystem gelten fünf gleichmäßig verteilte Linien. Gewählt
        wird das System, das der Tipp-Stelle am nächsten liegt; Hilfslinien
        bis sechs Linienabstände darüber oder darunter sind erlaubt.
    *   Der Abstand zur untersten Linie in halben Linienabständen ergibt
        die Stufe. Daraus berechnet die App mit Schlüssel und Vorzeichen
        den MIDI-Wert.
    *   Tests prüfen das mit gezeichneten Notenbildern.
*   **App-Symbol:** Bordeaux mit goldenen Notenlinien und einer
    cremefarbenen Achtelnote. Es liegt in
    `ChorAssistent/Assets.xcassets/AppIcon.appiconset`.

## Alternatives Considered

Es gab keine vorangehende Brainstorm-Phase. Die folgenden Alternativen wurden
in der Entwurfssitzung am 2026-11-15 vorgelegt und vom Autor abgelehnt. Der
Autor hat jeweils gewählt, ohne eine eigene Begründung zu nennen. Als Grund für
die Ablehnung steht deshalb der Nachteil, der in der Sitzung zu der jeweiligen
Option genannt wurde.

### Plattform

#### Alternative P1: Web-App (PWA)

*   **Pros:** Läuft auf jedem Gerät ohne App Store. Kein Mac nötig, keine
    7-Tage-Signatur. Es gibt eine Codebasis.
*   **Cons:** Web Audio folgt auf iOS standardmäßig dem Stummschalter. G4 ist
    nur über Umwege erreichbar, deren Verhalten von der iOS-Version abhängt.
    Klangdatei und Daten liegen im Browser-Speicher.
*   **Reason for Rejection:** Vom Autor abgelehnt. Nachteil laut Sitzung: G4
    ist nativ verlässlich erreichbar. Wird die offene Frage zum Apple-Account
    ohne dauerhaften Mac und ohne bezahlten Account beantwortet, ist diese
    Ablehnung neu zu prüfen.

#### Alternative P2: Native Android-App

*   **Pros:** Volle Kontrolle über das Gerät, kein Mac nötig.
*   **Cons:** Läuft nicht auf dem iPhone.
*   **Reason for Rejection:** Vom Autor abgelehnt. Nachteil laut Sitzung: Das
    Zielgerät ist ein iPhone.

#### Alternative P3: Cross-Platform (Flutter / React Native)

*   **Pros:** Eine Codebasis für iOS und Android.
*   **Cons:** Zusätzliche Werkzeuge und eine weitere Schicht über der
    Audio-API. Für den iOS-Build braucht man trotzdem einen Mac.
*   **Reason for Rejection:** Vom Autor abgelehnt. Nachteil laut Sitzung:
    Android ist kein Ziel, also bringt die zusätzliche Schicht keinen Nutzen.

### Art der Töne

#### Alternative T1: Eigene Tonaufnahmen

*   **Pros:** Klingt wie das eigene Instrument oder die eigene Stimmgabel.
*   **Cons:** Braucht Mikrofon-Berechtigung und Audiodateien. Die Stimmung
    hängt von der Aufnahme ab und lässt sich nicht nachträglich anpassen.
*   **Reason for Rejection:** Vom Autor abgelehnt. Nachteil laut Sitzung: Töne
    aus Notennamen kommen aus einer einmal geprüften Klangdatei (siehe offene
    Frage SoundFont) und hängen nicht von einer eigenen Aufnahme ab.

#### Alternative T2: Aufnahmen und Notennamen wählbar

*   **Pros:** Die flexibelste Lösung.
*   **Cons:** Zwei Funktionen müssen gebaut und getestet werden.
*   **Reason for Rejection:** Vom Autor abgelehnt. Nachteil laut Sitzung:
    Doppelter Aufwand ohne benannten Bedarf.

### Abspielweise

#### Alternative A1: Ein Knopf pro Stimme

*   **Pros:** Jede Stimme hört gezielt ihren Ton.
*   **Cons:** Im Konzert braucht man mehr Tipps pro Lied, und jeder Ton
    braucht ein Stimmen-Label.
*   **Reason for Rejection:** Vom Autor abgelehnt. Nachteil laut Sitzung: Ein
    Tipp pro Lied ist auf der Bühne schneller.

#### Alternative A2: Alle Töne als Akkord

*   **Pros:** Man hört Tonart und Gesamtklang.
*   **Cons:** Einzelne Stimmen hören ihren Ton schlechter heraus.
*   **Reason for Rejection:** Vom Autor abgelehnt. Nachteil laut Sitzung:
    Nacheinander gespielte Töne lassen sich einzeln erkennen.

#### Alternative A3: Alle drei Abspielweisen wählbar

*   **Pros:** Deckt jede Situation ab.
*   **Cons:** Mehr Oberfläche und mehr Möglichkeiten, sich auf der Bühne zu
    vertippen.
*   **Reason for Rejection:** Vom Autor abgelehnt. Nachteil laut Sitzung: Mehr
    Bedienelemente erhöhen das Risiko von Fehlbedienung im Konzert.

### Nutzer und Datenhaltung

#### Alternative N1: Synchronisierung über iCloud (CloudKit) zwischen eigenen Geräten

*   **Pros:** Daten auf iPhone und iPad gleich. Bei Geräteverlust sind die
    Daten noch in der Cloud.
*   **Cons:** Sync-Konflikte, bezahlter Apple-Entwickleraccount nötig,
    schwerer zu testen.
*   **Reason for Rejection:** Vom Autor abgelehnt. Nachteil laut Sitzung: Nur
    ein Gerät wird genutzt. Gegen Datenverlust schützen der Export (G7) und
    das Geräte-Backup.

#### Alternative N2: Gemeinsame Nutzung mit Chormitgliedern

*   **Pros:** Sänger*innen sehen das Programm und die Töne.
*   **Cons:** Braucht Server oder CloudKit-Freigabe, Konten und Rechte. Das
    vervielfacht den Aufwand.
*   **Reason for Rejection:** Vom Autor abgelehnt. Nachteil laut Sitzung: Das
    Problem ist das Tonangeben durch eine Person, nicht das Verteilen von
    Informationen.

### Tonerzeugung

#### Alternative K1: Eigene Synthese mit `AVAudioSourceNode`

*   **Pros:** Keine Klangdatei, keine Lizenzfrage, mathematisch exakte
    Stimmung.
*   **Cons:** Klingt wie eine elektronische Orgel. Echtzeit-Audiocode ist
    fehleranfällig, weil im Audio-Thread weder Speicher reserviert noch
    gesperrt werden darf.
*   **Reason for Rejection:** Vom Autor abgelehnt. Nachteil laut Sitzung: Ein
    Klavierklang ist für den Chor vertrauter und im Raum besser als Tonhöhe zu
    erkennen. Der Preis dafür ist die Abhängigkeit von einer geprüften
    SoundFont-Datei.

### Datenspeicherung

#### Alternative D1: Eine JSON-Datei (`Codable`)

*   **Pros:** Reihenfolgen sind einfache Arrays. Speicherformat und
    Exportformat sind dasselbe. Leicht zu testen.
*   **Cons:** Versionierung und Migration des Formats muss man selbst bauen.
    Ohne Migration macht eine Formatänderung alte Dateien unlesbar.
*   **Reason for Rejection:** Vom Autor abgelehnt. Nachteil laut Sitzung:
    SwiftData passt direkt zu SwiftUI und braucht weniger eigenen Code zum
    Speichern. Das Exportformat muss deshalb getrennt gepflegt werden.

#### Alternative D2: Core Data

*   **Pros:** Ausgereift, unterstützt geordnete Beziehungen direkt, leichte
    Migrationen laufen automatisch.
*   **Cons:** Der meiste Code und die schlechteste Anbindung an SwiftUI.
*   **Reason for Rejection:** Vom Autor abgelehnt. Nachteil laut Sitzung: Zu
    viel Code für eine App dieser Größe.

### Reihenfolge im Konzert

#### Alternative R1: Array `songIDs: [UUID]` am Konzert

*   **Pros:** Die Reihenfolge ist ein Array, Umsortieren ist ein einfaches
    Verschieben. Kein `position`-Feld, das gepflegt werden muss.
*   **Cons:** Keine echte Beziehung. Beim Löschen eines Lieds muss eigener Code
    verwaiste IDs entfernen. Daten pro Eintrag lassen sich später schwer
    ergänzen.
*   **Reason for Rejection:** Vom Autor abgelehnt, und nach den Prüfstufen 5,
    7 und 8 bewusst bestätigt. Die Prüfer hielten `ConcertEntry` für
    vermeidbaren Aufwand und empfahlen R1 oder ein Array von Slots. Der Autor
    behält echte Beziehungen mit `.cascade`. Die Kosten sind bekannt:
    *   Speicher und Export stellen die Reihenfolge verschieden dar
        (`position` bzw. `songIDs`).
    *   Die Positionen müssen gepflegt werden.

    Begrenzt wird das Risiko durch eine einzige `renumber`-Funktion, eine
    festgelegte Reihenfolge beim Löschen und Tests.

--------------------------------------------------------------------------------

## Future Improvements

*   **Kammerton einstellbar:** über `sampler.globalTuning = 1200 · log2(ref /
    440)` Cent nachrüstbar, ohne das Datenmodell zu ändern.
*   **Englische Schreibweise:** nur `NoteName` muss erweitert werden.
*   **Einzelne Töne pro Stimme abspielen:** Dafür bräuchte jeder Ton ein
    Stimmen-Label. Das ist eine Änderung am Datenmodell mit Migration.

## Additional Resources

*   SoundFont-Quellen (Stand 2026-11-15):
    *   [FreePats Piano-Seite](https://freepats.zenvoid.org/Piano/acoustic-grand-piano.html):
        enthält den Hauptkandidaten „Upright Piano KW, small, SF2" (CC0,
        10 MiB entpackt).
    *   [Salamander Grand Piano (sfzinstruments)](https://github.com/sfzinstruments/SalamanderGrandPiano):
        ausgeschieden. SFZ-Format; die SF2-Ausgabe ist 296 MiB groß; CC-BY 3.0.
    *   [Velocity Grand Piano (Polyphone)](https://polyphone.io/en/soundfonts/pianos/127-velocity-grand-piano):
        laut Polyphone-Seite Public Domain, Autor unbekannt, Herkunft der
        Samples ungeklärt (die Seite nennt „Piano set (Stephane Bernard)" als
        Quelle). Ca. 0,9 MB, nur 9 Samples; die Wechsel zwischen den Samples
        können hörbar sein. Download nur mit Konto.

--------------------------------------------------------------------------------

## Detailed Implementation Plan

Alle Pfade sind relativ zum Projekt-Stammordner `ChorAssistent/`, also auf
dem Mac dem Ordner, in dem `ChorAssistent.xcodeproj` liegt.

**Rahmen:**
*   Deployment Target iOS 17.0, nur iPhone, nur Hochformat.
*   Xcode 16 oder neuer, Swift-Sprachmodus 5, Build-Einstellung
    `SWIFT_STRICT_CONCURRENCY = complete`.
*   Keine Abhängigkeiten von Drittanbietern.

Die Umsetzung läuft in 8 Phasen. Nach jeder Phase lässt sich das Projekt
bauen, und die bis dahin geschriebenen Tests laufen durch. Erst wenn der
**Prüfpunkt** einer Phase erfüllt ist, beginnt die nächste.

### Phase 0: Voraussetzungen (vor jedem Code)

1.  **Mac und Signatur:**
    *   Einen Mac mit Xcode 16 oder neuer festlegen, auf den man **dauerhaft**
        Zugriff hat (siehe offene Frage).
    *   Am iPhone den Entwicklermodus einschalten. In Xcode mit der
        kostenlosen Apple-ID anmelden („Personal Team").
    *   Die Bundle-ID lautet `local.chorassistent.ChorAssistent`. Ist sie
        vergeben, wird ein Suffix angehängt.
2.  **SoundFont beschaffen:**
    *   Herunterladen: „Upright Piano KW, small, SF2" von der
        [FreePats-Seite](https://freepats.zenvoid.org/Piano/acoustic-grand-piano.html).
        Das ist ein `.7z`-Archiv, gepackt 5,8 MiB, entpackt 10 MiB.
    *   Entpacken mit `7zz x <Datei>.7z`. Das Werkzeug kommt über
        `brew install sevenzip`.
    *   Die SF2-Datei in `Piano.sf2` umbenennen.
3.  **Annahmekriterien prüfen.** Alle müssen erfüllt sein:
    *   Lizenztext im Archiv lesen: CC0 1.0.
    *   Dateigröße der `.sf2` höchstens 30 MB.
    *   Die Datei enthält ein Preset in Bank 0 / Program 0. Das wird in Phase 3
        geprüft: `loadSoundBankInstrument` mit Program 0 läuft ohne Fehler.
    *   Die Stimmung wird in Phase 4 auf dem Gerät geprüft (siehe Prüfplan,
        Schritt M3).

    Ist eines dieser Kriterien nicht erfüllt, ist der Ersatz die Variante
    „small, bright, SF2" derselben Seite. Erfüllt auch sie die Kriterien
    nicht, wird die Umsetzung angehalten, und die SoundFont-Frage geht zurück
    an den Autor.

**Prüfpunkt 0:** Mac und Apple-ID funktionieren, das heißt, eine leere
Test-App startet auf dem iPhone. `Piano.sf2` liegt vor.

### Phase 1: Projektgerüst

> **Geändert am 2026-11-15:** Das Projekt wird nicht mehr über die
> Xcode-Vorlage angelegt. `project.yml` (XcodeGen) beschreibt beide Targets
> mit den Einstellungen aus Datei 1. Die Schritte zum Löschen der
> Vorlagendateien (Datei 2 und 3) entfallen. Ein Asset-Katalog (Datei 4) ist
> noch nicht angelegt, deshalb hat die App vorerst das Standard-Symbol. Der
> Workflow `.github/workflows/ios.yml` übernimmt Build, Tests, Lint und die
> unsignierte `.ipa`.

#### 1. `ChorAssistent.xcodeproj` (Create)

*   **Type / Scope:** Xcode-Projekt.
*   **Proposed Changes:**
    *   Anlegen über „New Project › iOS › App" mit diesen Einstellungen:
        *   Interface SwiftUI, Storage „None"
        *   Testing System „Swift Testing"
        *   „Include Tests" an, aber nur Unit-Tests
    *   Die Vorlage erzeugt zusätzlich ein Target `ChorAssistentUITests`. Es
        wird gelöscht, zusammen mit seinem Ordner.
    *   Es bleiben genau zwei Targets: `ChorAssistent` und
        `ChorAssistentTests`.
    *   Einstellungen: Deployment Target 17.0, Supported Destinations nur
        iPhone, Orientierung nur Portrait, Bundle-ID aus Phase 0, Team
        „Personal Team", `SWIFT_STRICT_CONCURRENCY = complete`.

#### 2. `ChorAssistent/ContentView.swift` (Delete)

*   **Type / Scope:** Datei aus der Vorlage.
*   **Proposed Changes:** Wird gelöscht. An ihre Stelle tritt
    `RootTabView` (Datei 17).

#### 3. `ChorAssistentTests/ChorAssistentTests.swift` (Delete)

*   **Type / Scope:** Beispieltest aus der Vorlage.
*   **Proposed Changes:** Wird gelöscht. Die Tests stehen in den Dateien
    T1–T6.

#### 4. `ChorAssistent/Assets.xcassets` (Modify)

*   **Type / Scope:** Asset-Katalog aus der Vorlage. Er bleibt an diesem
    Pfad. Auch `ChorAssistent/Preview Content/` bleibt unverändert.
*   **Proposed Changes:** App-Symbol 1024×1024 (eine Note auf einfarbigem
    Hintergrund) und eine Akzentfarbe.

#### 5. `.swift-format` (Create)

*   **Type / Scope:** Konfiguration für den Linter.
*   **Proposed Changes:** JSON mit `"version": 1`,
    `"indentation": { "spaces": 4 }` und `"lineLength": 120`. Alle übrigen
    Regeln bleiben auf dem Standard. Damit passt die Prüfung zur Einrückung,
    die Xcode verwendet.

#### 6. `ChorAssistent/ChorAssistentApp.swift` (Modify, aus der Vorlage)

*   **Type / Scope:** Einstieg der App.
*   **Proposed Changes:**
    *   `@main struct ChorAssistentApp: App`.
    *   In `init` wird zuerst `PlaybackSettings.registerDefaults()`
        aufgerufen.
    *   `@State private var tonePlayer = TonePlayer()`. Im `init` folgt
        `tonePlayer.setUp()`.
    *   **Datenbank:** Der `ModelContainer` für `Song`, `Concert` und
        `ConcertEntry` wird mit `try` erzeugt.
        *   Schlägt das fehl, zeigt die App statt `RootTabView` eine
            `StartupErrorView` (Datei 29) mit dem Fehlertext. Sie stürzt
            nicht ab.
    *   `@Environment(\.scenePhase)`:
        *   Bei `.active` folgt `tonePlayer.ensureRunning()`.
        *   Bei `.background` folgt `tonePlayer.stop()`.
    *   Die Bildschirmsperre wird hier **nicht** angefasst. Das macht nur der
        Konzertmodus (Datei 25).
    *   Übergabe: `.modelContainer(container)` und `.environment(tonePlayer)`.

**Prüfpunkt 1:** Die App startet auf dem Simulator mit drei leeren Reitern.
`xcodebuild build` läuft ohne Warnungen.

### Phase 2: Modelle, Notennamen, Reihenfolge

#### 7. `ChorAssistent/Models/Song.swift` (Create)

*   **Type / Scope:** SwiftData-Modell plus Prüfregeln.
*   **Proposed Changes:**
    *   `@Model final class Song` mit:
        *   `var id: UUID`, `title: String`, `memo: String`,
            `pitches: [Int]`, `createdAt: Date`. **Kein** `.unique`, **kein**
            `updatedAt`.
        *   `@Relationship(deleteRule: .cascade, inverse: \ConcertEntry.song)
            var entries: [ConcertEntry] = []`.
    *   `init(id: UUID = UUID(), title:, memo: = "", pitches:, createdAt: =
        .now)`.
    *   Statische Konstanten `pitchRange = 36...84` und `maxPitches = 8`.
    *   `enum SongValidationError: Error, Equatable` mit den Fällen:
        *   `emptyTitle`
        *   `noPitches`
        *   `tooManyPitches`
        *   `pitchOutOfRange(Int)`
    *   `static func validate(title: String, pitches: [Int]) ->
        SongValidationError?`. Den Titel prüft sie nach Trimmen von
        Leerraum.
    *   Diese eine Funktion benutzen sowohl das Formular (Datei 19) als auch
        der Import (Datei 27).

#### 8. `ChorAssistent/Models/ConcertEntry.swift` (Create)

*   **Type / Scope:** SwiftData-Modell.
*   **Proposed Changes:** `@Model final class ConcertEntry` mit:
    *   `var id: UUID = UUID()`
    *   `var position: Int`
    *   `var song: Song?`
    *   `var concert: Concert?`
    *   `init(position:, song:, concert:)`

#### 9. `ChorAssistent/Models/Concert.swift` (Create)

*   **Type / Scope:** SwiftData-Modell plus Reihenfolge-Logik. Die Datei
    importiert kein SwiftUI.
*   **Proposed Changes:**
    *   **Modell:** `@Model final class Concert` mit `var id: UUID`,
        `name: String`, `createdAt: Date`,
        `@Relationship(deleteRule: .cascade, inverse: \ConcertEntry.concert)
        var entries: [ConcertEntry] = []`, `init(name:)`.
    *   **`var orderedEntries: [ConcertEntry]`:**
        *   Schließt Einträge mit `isDeleted == true` oder `song == nil` aus.
        *   Sortiert nach `(position, id.uuidString)`.
    *   **`func renumber(orderedEntries: [ConcertEntry])`:**
        *   Setzt `position = index` für jeden übergebenen Eintrag.
        *   Das ist die **einzige** Stelle, die `position` schreibt.
    *   **`func append(song: Song, in context: ModelContext)`:**
        1.  Legt einen Eintrag mit `position = orderedEntries.count` an,
            also ans Ende.
        2.  Fügt ihn ein.
        3.  Ruft `renumber(orderedEntries: orderedEntries + [neu])` auf.
    *   **`func remove(atOffsets offsets: IndexSet, in context:)`:**
        1.  Liest `current = orderedEntries`.
        2.  Bildet `remaining` = `current` ohne die Einträge an diesen
            Positionen.
        3.  Löscht die entfernten Einträge.
        4.  Ruft `renumber(orderedEntries: remaining)` auf.
    *   **`func move(fromOffsets source: IndexSet, toOffset destination: Int)`:**
        *   Verschiebt auf einer Kopie von `orderedEntries`.
        *   Benutzt dafür eine private Hilfsfunktion in dieser Datei, die die
            Semantik von SwiftUIs `move(fromOffsets:toOffset:)` nachbildet:
            Elemente bei `source` herausnehmen und vor dem ursprünglichen
            Index `destination` einfügen.
        *   Ruft danach `renumber(orderedEntries: kopie)` auf.

#### 10. `ChorAssistent/Models/LibraryActions.swift` (Create)

*   **Type / Scope:** Änderungen, die mehrere Modelle betreffen.
*   **Proposed Changes:** `enum LibraryActions`.
    *   **`static func delete(song: Song, in context: ModelContext) throws`**
        arbeitet in dieser Reihenfolge:
        1.  Für jedes Konzert, in dem das Lied vorkommt:
            `remaining = concert.orderedEntries.filter { $0.song !== song }`,
            dann `concert.renumber(orderedEntries: remaining)`.
        2.  `context.delete(song)`. Die Einträge des Lieds löscht `.cascade`.
        3.  `try context.save()`.
    *   **`static func concertCount(for song: Song) -> Int`:** Anzahl
        verschiedener Konzerte, in denen das Lied vorkommt.

#### 11. `ChorAssistent/Music/NoteName.swift` (Create)

*   **Type / Scope:** Reine Logik.
*   **Proposed Changes:** `enum NoteName` mit:
    *   **`pitchClasses`:** `["C","Cis","D","Dis","E","F","Fis","G","Gis","A","B","H"]`
    *   **`pickerLabels`:** `["C","Cis/Des","D","Dis/Es","E","F","Fis/Ges","G","Gis/As","A","B (= B♭)","H (= B)"]`
    *   **`static func name(midi: Int) -> String`:**
        `pitchClasses[midi % 12] + String(midi / 12 - 1)`, z. B. 70 → „B4".
    *   **`static func pickerLabel(pitchClass: Int) -> String`.**
    *   **`static func midi(pitchClass: Int, octave: Int) -> Int`:**
        `(octave + 1) * 12 + pitchClass`.
    *   **`static func components(midi: Int) -> (pitchClass: Int, octave: Int)`.**
    *   **`static func names(_ pitches: [Int]) -> String`:** Die Namen werden
        mit „, " verbunden.

**Prüfpunkt 2:** Die Tests T1, T3 und T4 laufen durch.

### Phase 3: Audio

#### 12. `ChorAssistent/Settings/PlaybackSettings.swift` (Create)

*   **Type / Scope:** Einstellungen.
*   **Proposed Changes:** `enum PlaybackSettings`.
    *   **Schlüssel:** `toneDurationKey = "toneDuration"`, `gapKey = "gap"`.
    *   **Standardwerte:** `defaultToneDuration = 1.0`, `defaultGap = 0.15`.
    *   **Bereiche und Schrittweiten:** `toneDurationRange = 0.5...3.0` mit
        Schrittweite 0.1. `gapRange = 0.0...1.0` mit Schrittweite 0.05.
    *   **`static func registerDefaults()`:** ruft
        `UserDefaults.standard.register(defaults:)` mit beiden Standardwerten
        auf. Ohne das liefert `double(forKey:)` vor der ersten Änderung 0.
    *   **`static func clamp(_ value: Double, to range:) -> Double`.**
    *   **`static var toneDurationMs: Int` und `static var gapMs: Int`:**
        lesen aus `UserDefaults.standard`, begrenzen auf den Bereich und
        runden auf ganze Millisekunden.

#### 13. `ChorAssistent/Audio/PlaybackSchedule.swift` (Create)

*   **Type / Scope:** Reine Logik, ganzzahlige Millisekunden. Damit es keine
    Rundungsfehler gibt.
*   **Proposed Changes:**
    *   `enum NoteEventKind { case start, stop }`
    *   `struct NoteEvent: Equatable { timeMs: Int; midi: Int; kind:
        NoteEventKind }`
    *   **`enum PlaybackSchedule`** mit `static func events(pitches: [Int],
        toneDurationMs: Int, gapMs: Int) -> [NoteEvent]`:
        *   Ton i startet bei `i * (toneDurationMs + gapMs)` und stoppt bei
            `start + toneDurationMs`.
        *   Die Liste ist nach `timeMs` sortiert.
        *   Bei gleicher Zeit steht `stop` **vor** `start`. Dadurch schneidet
            ein wiederholter Ton bei Pause 0 den nächsten nicht ab.

#### 14. `ChorAssistent/Audio/TonePlayer.swift` (Create)

*   **Type / Scope:** Audio-Dienst, `@MainActor @Observable final class
    TonePlayer`.
*   **Zustand:**
    *   `private var engine: AVAudioEngine` und `private var sampler:
        AVAudioUnitSampler`, beide `var`, damit sie sich neu aufbauen lassen
    *   `private var playTask: Task<Void, Never>?`
    *   `private var generation = 0`
    *   `private var soundingNotes: Set<UInt8> = []`
    *   `private(set) var isPlaying = false`
    *   `private(set) var currentSourceID: String?`
    *   `private(set) var lastError: AudioError?`
*   **`enum AudioError`:** einziger Fall `.unavailable`. Die Meldung lautet
    „Ton nicht verfügbar – App neu starten".
*   **`setUp()`** wird einmal beim App-Start aufgerufen:
    1.  Sitzung: `setCategory(.playback, mode: .default, options:
        [.mixWithOthers])`.
    2.  `buildGraph()`, dann `ensureRunning()`.
    3.  Für jede Benachrichtigung einen Beobachter mit
        `addObserver(forName:object:queue: .main)` registrieren. Werte aus
        `userInfo` werden im Beobachter als Sendable-Werte ausgelesen. Danach
        wechselt der Code mit `MainActor.assumeIsolated` in den
        MainActor-Kontext. Ursprünglich war hier
        `notifications(named:)` in einem `@MainActor`-Task vorgesehen. Dabei
        überquert der nicht-Sendable-Typ `Notification` die Actor-Grenze, und
        das erzeugt unter strenger Prüfung Warnungen.

        | Benachrichtigung | Reaktion |
        |---|---|
        | `AVAudioSession.interruptionNotification` | Typ `.began` → `stop()`; Typ `.ended` → `ensureRunning()` |
        | `AVAudioSession.routeChangeNotification` | `ensureRunning()` |
        | `.AVAudioEngineConfigurationChange` | `ensureRunning()` |
        | `AVAudioSession.mediaServicesWereResetNotification` | `rebuild()` |

    `setUp()` wird nie erneut aufgerufen, damit sich die Beobachter nicht
    stapeln.
*   **`private func buildGraph()`:**
    1.  Neue Instanzen von `AVAudioEngine` und `AVAudioUnitSampler` anlegen.
    2.  `attach` und `connect` an den `mainMixerNode`.
    3.  Die SoundFont laden:
        `try sampler.loadSoundBankInstrument(at: Bundle.main.url(forResource:
        "Piano", withExtension: "sf2")!, program: 0, bankMSB: UInt8(kAUSampler_DefaultMelodicBankMSB),
        bankLSB: UInt8(kAUSampler_DefaultBankLSB))`. Die Konstanten haben
        die Werte 0x79 und 0.
    4.  Bei einem Fehler: `lastError = .unavailable`.
*   **`func ensureRunning()`:**
    1.  `try AVAudioSession.sharedInstance().setActive(true)`.
    2.  Läuft die Engine nicht (`!engine.isRunning`): `engine.prepare()`,
        dann `try engine.start()`.
    3.  Bei Erfolg `lastError = nil`, bei einem Fehler `lastError =
        .unavailable`.
*   **`private func rebuild()`:** `stop()`, dann `buildGraph()`, dann
    `ensureRunning()`.
*   **`func play(_ pitches: [Int], sourceID: String, toneDurationMs: Int =
    PlaybackSettings.toneDurationMs, gapMs: Int = PlaybackSettings.gapMs)`:**
    1.  `ensureRunning()`. Gibt es danach `lastError`, wird abgebrochen.
    2.  `stop()`, dann `generation += 1` und den Wert merken.
    3.  `currentSourceID = sourceID`, `isPlaying = true`.
    4.  `playTask` startet und arbeitet die Ereignisse von
        `PlaybackSchedule.events` ab:
        *   Für jedes Ereignis: `try? await clock.sleep(until: start +
            .milliseconds(e.timeMs))` mit `ContinuousClock`. Die Zeitpunkte
            sind absolut, damit sich keine Verzögerung aufsummiert.
        *   Danach: Ist `Task.isCancelled` gesetzt oder hat sich
            `generation` geändert, endet der Ablauf.
        *   `start` → `sampler.startNote(UInt8(midi), withVelocity: 127,
            onChannel: 0)` und `soundingNotes.insert`.
        *   `stop` → `stopNote` und `remove`.
    5.  Am Ende, wenn `generation` noch gleich ist: `isPlaying = false` und
        `currentSourceID = nil`.
*   **`func preview(_ midi: Int)`:** `play([midi], sourceID: "preview",
    toneDurationMs: 500, gapMs: 0)`. Eine Vorschau bricht also einen
    laufenden Ablauf ab.
*   **`func stop()`:**
    1.  `playTask?.cancel()`, dann `generation += 1`.
    2.  `stopNote` für alle `soundingNotes`. Zusätzlich
        `sampler.sendController(123, withValue: 0, onChannel: 0)`, das ist
        „All Notes Off".
    3.  `soundingNotes = []`, `isPlaying = false`, `currentSourceID = nil`.

#### 15. `ChorAssistent/Audio/AudioRouteMonitor.swift` (Create)

*   **Type / Scope:** `@MainActor @Observable final class AudioRouteMonitor`.
    Den Monitor besitzt der Konzertmodus.
*   **Zustand:** `private(set) var outputName: String` und
    `private(set) var isVolumeLow: Bool`.
*   **`start()`:**
    *   Liest `AVAudioSession.sharedInstance().currentRoute.outputs.first?.portType`
        und macht daraus einen Namen:

        | `portType` | Anzeige |
        |---|---|
        | `.builtInSpeaker` | „iPhone-Lautsprecher" |
        | `.headphones`, `.bluetoothHFP` | „Kopfhörer" |
        | `.bluetoothA2DP`, `.bluetoothLE` | „Bluetooth" |
        | `.airPlay` | „AirPlay" |
        | sonst | „Anderes Gerät" |

    *   Beobachtet `outputVolume` per KVO (`observe(\.outputVolume, options:
        [.initial, .new])`). Es gilt `isVolumeLow = volume < 0.3`.
    *   Startet einen Task mit `notifications(named:
        AVAudioSession.routeChangeNotification)`, der den Namen neu liest.
*   **`stop()`:** Die KVO-Beobachtung und der Task enden.

#### 16. `ChorAssistent/Views/Shared/AudioErrorBanner.swift` (Create)

*   **Type / Scope:** SwiftUI-`ViewModifier` `.audioErrorBanner()`.
*   **Proposed Changes:**
    *   Ist `tonePlayer.lastError` gesetzt, erscheint oben ein rotes Banner
        mit dem Text aus `AudioError`.
    *   Der Modifier wird in `RootTabView` **und** in `ConcertPlayerView`
        benutzt. Die Vollbild-Ansicht würde ein Banner aus `RootTabView`
        sonst verdecken.

**Prüfpunkt 3:** Die Tests in T2 laufen durch. Die App baut ohne
Warnungen unter strenger Nebenläufigkeit.

### Phase 4: Liederbibliothek

#### 17. `ChorAssistent/Views/RootTabView.swift` (Create)

*   **Type / Scope:** SwiftUI.
*   **Proposed Changes:**
    *   `TabView` mit den Reitern „Lieder" (`music.note.list`), „Konzerte"
        (`music.mic`) und „Einstellungen" (`gearshape`).
    *   Jeder Reiter hat einen eigenen `NavigationStack`.
    *   `.audioErrorBanner()`.
    *   Ab Phase 7 kommt zusätzlich die Signaturwarnung dazu (Datei 31).

#### 18. `ChorAssistent/Views/Songs/SongListView.swift` (Create)

*   **Type / Scope:** SwiftUI.
*   **Proposed Changes:**
    *   `@Query(sort: \Song.title)` und `.searchable` auf den Titel.
    *   **Zeile:** Titel und `NoteName.names(pitches)` sowie
        `PlayButton(pitches:, sourceID: song.id.uuidString, size:
        .regular)`.
    *   Antippen der Zeile öffnet `SongEditView` im Bearbeiten-Modus. „+"
        öffnet sie als Sheet im Anlegen-Modus.
    *   **Löschen per Wischen:**
        1.  `confirmationDialog` mit dem Text „‚<Titel>' löschen? Es kommt in
            <n> Konzerten vor." Die Zahl kommt aus
            `LibraryActions.concertCount`.
        2.  Danach `LibraryActions.delete`.

#### 19. `ChorAssistent/Views/Songs/SongEditView.swift` (Create)

*   **Type / Scope:** SwiftUI-Formular.
*   **Proposed Changes:**
    *   Arbeitet auf einem lokalen Entwurf `struct SongDraft { var title:
        String; var memo: String; var pitches: [Int] }`, der in derselben
        Datei definiert ist.
    *   **Abschnitte:**
        *   Titel
        *   Notiz (`TextField`, höchstens 200 Zeichen)
        *   Töne als Liste mit Notennamen. Antippen eines Tons öffnet den
            `PitchPicker` als Sheet, um diesen Ton zu ändern. Dazu kommen
            `.onMove` und `.onDelete`.
        *   „Ton hinzufügen" öffnet den `PitchPicker` als Sheet. Der
            Startwert ist der letzte Ton, sonst A4 (69). Bei 8 Tönen ist der
            Knopf deaktiviert.
        *   `PlayButton(pitches: draft.pitches, sourceID: "edit")`.
    *   **„Sichern":** ist deaktiviert, solange `Song.validate` einen Fehler
        liefert. Der Fehlergrund steht als Fußzeile im Formular. Beim Sichern
        werden die Werte des Entwurfs auf das Modell geschrieben bzw. ein
        neues `Song` eingefügt, danach folgt `try context.save()`.
    *   `.onDisappear { tonePlayer.stop() }`.

#### 20. `ChorAssistent/Views/Songs/PitchPicker.swift` (Create)

*   **Type / Scope:** SwiftUI-Sheet mit `Binding<Int>` (MIDI).
*   **Proposed Changes:**
    *   **Zwei Räder:**
        *   Tonname mit den Labels aus `NoteName.pickerLabel`.
        *   Oktave 2–6.
    *   **Oktave 6:** Ist sie gewählt, enthält das Tonname-Rad nur „C", und
        die Tonklasse wird auf 0 gesetzt. So kann kein Ton über C6 entstehen.
    *   Jede Änderung ruft `tonePlayer.preview(midi)` auf.
    *   „Fertig" schließt das Sheet.

#### 21. `ChorAssistent/Views/Shared/PlayButton.swift` (Create)

*   **Type / Scope:** SwiftUI-Komponente.
*   **Proposed Changes:** `PlayButton(pitches: [Int], sourceID: String,
    size: .regular | .large)`.
    *   **Symbol:**
        *   „arrow.counterclockwise" nur, wenn `tonePlayer.isPlaying &&
            tonePlayer.currentSourceID == sourceID`.
        *   Sonst „play.fill". Andere Zeilen zeigen also weiter das
            Play-Symbol.
    *   **Antippen:** `tonePlayer.play(pitches, sourceID:)`. Das startet
        dieselbe Folge neu oder wechselt zu einer anderen Folge.
    *   Bei leerer Liste ist der Knopf deaktiviert.
    *   **Gestoppt wird der Ton:**
        *   beim Verlassen von `SongEditView` und `ConcertPlayerView`
        *   beim Liedwechsel im Konzertmodus
        *   beim Wechsel der App in den Hintergrund

**Prüfpunkt 4:** Auf dem iPhone wurden die Prüfschritte M1–M3 (CUJ 1 und
CUJ 2, Stummschalter, Stimmung) bestanden.

### Phase 5: Konzerte und Konzertmodus

#### 22. `ChorAssistent/Views/Concerts/ConcertListView.swift` (Create)

*   **Type / Scope:** SwiftUI.
*   **Proposed Changes:**
    *   `@Query(sort: \Concert.createdAt, order: .reverse)`.
    *   **Zeile:** Name und „<n> Lieder".
    *   „+" öffnet einen `alert` mit `TextField` für den Namen.
    *   Löschen per Wischen mit `confirmationDialog`.
    *   Antippen öffnet `ConcertEditView`.
    *   Ab Phase 7 steht oben `SignatureStatusView` (Datei 31).

#### 23. `ChorAssistent/Views/Concerts/ConcertEditView.swift` (Create)

*   **Type / Scope:** SwiftUI.
*   **Proposed Changes:**
    *   **Liste aus `orderedEntries`:** Nummer, Titel und Notennamen.
        *   `.onMove` ruft `concert.move` auf, `.onDelete` ruft
            `concert.remove` auf.
        *   Danach jeweils `try context.save()`.
    *   **Name:** lässt sich über ein `TextField` im Kopf umbenennen.
    *   **Knöpfe:**
        *   „Lied hinzufügen" öffnet `SongPickerSheet`.
        *   Ein Knopf „Konzert starten" am unteren Rand (`.borderedProminent`,
            `.controlSize(.large)`) öffnet `ConcertPlayerView` als
            `fullScreenCover`. Bei 0 Einträgen ist er deaktiviert.

#### 24. `ChorAssistent/Views/Concerts/SongPickerSheet.swift` (Create)

*   **Type / Scope:** SwiftUI.
*   **Proposed Changes:**
    *   Durchsuchbare Liste aller Lieder.
    *   Antippen ruft `concert.append` und `save()` auf. Das Sheet bleibt
        offen.
    *   Rechts steht „×n", wenn das Lied schon n-mal im Konzert vorkommt.
    *   „Fertig" schließt das Sheet.

#### 25. `ChorAssistent/Views/Concerts/ConcertPlayerView.swift` (Create)

*   **Type / Scope:** SwiftUI, Vollbild.
*   **Zustand:**
    *   `@State currentIndex = 0`.
    *   Die Ansicht liest bei jedem Rendern **live** `concert.orderedEntries`.
        Es gibt keinen Schnappschuss und keinen Zustand „Lied gelöscht".
    *   `currentIndex` wird auf `0..<count` begrenzt.
    *   `@State routeMonitor = AudioRouteMonitor()`.
*   **Aufbau von oben nach unten:**
    *   **Kopfzeile:**
        *   links „Beenden": `confirmationDialog` „Konzertmodus beenden?",
            danach `dismiss`
        *   Mitte „Lied n von N" als Knopf
        *   rechts das Ausgabegerät aus `routeMonitor.outputName`
    *   **Warnzeile:** Bei `routeMonitor.isVolumeLow` gelb „Lautstärke
        niedrig".
    *   **Mitte:**
        *   Titel in `.largeTitle`
        *   Notennamen in `.title`
        *   Notiz in `.body`
    *   **Abspielen:** `PlayButton(size: .large)`, Höhe 50 % der
        Bildschirmhöhe.
    *   **Untere Zeile:**
        *   „Zurück" und „Weiter" mit Höhe 80 pt. Am ersten bzw. letzten
            Lied deaktiviert.
        *   „Als Nächstes: <Titel>" in `.footnote`.
    *   Es gibt **keine** Wischgesten und **kein** `TabView`.
*   **Sprung zu einem Lied:** Antippen von „Lied n von N" öffnet ein `.sheet`
    mit der Liste des Konzerts. Antippen eines Lieds ruft
    `tonePlayer.stop()` auf, setzt `currentIndex` und schließt das Sheet.
*   **Liedwechsel:** Jeder Wechsel ruft `tonePlayer.stop()` auf.
*   **Bildschirmsperre, die einzige Stelle:**
    `.onChange(of: scenePhase, initial: true) {
    UIApplication.shared.isIdleTimerDisabled = (scenePhase == .active) }`.
    `.onDisappear` setzt den Wert auf `false`.
*   `.onAppear` ruft `routeMonitor.start()` auf, `.onDisappear` ruft
    `routeMonitor.stop()` und `tonePlayer.stop()` auf.
*   `.audioErrorBanner()`.

**Prüfpunkt 5:** Auf dem iPhone wurden die Prüfschritte M4–M8 (CUJ 3,
CUJ 4, Bildschirmsperre, Anruf, Ausgabegerät) bestanden.

### Phase 6: Sicherung, Import, Rückgängig, Einstellungen

#### 26. `ChorAssistent/Backup/BackupFile.swift` (Create)

*   **Type / Scope:** `Codable`-DTOs.
*   **Proposed Changes:**
    *   **`struct BackupFile: Codable`:** `formatVersion: Int`, `exportedAt:
        Date`, `settings: SettingsDTO?`, `songs: [SongDTO]`, `concerts:
        [ConcertDTO]`.
    *   **`SongDTO`:** `id`, `title`, `memo`, `pitches`, `createdAt`. Der
        JSON-Schlüssel ist `"memo"`.
    *   **`ConcertDTO`:** `id`, `name`, `createdAt`, `songIDs: [UUID]`.
    *   **`SettingsDTO`:** `toneDuration`, `gap`.
    *   **`static let currentVersion = 1`.**
    *   **Encoder und Decoder:**
        *   Datumsformat `.iso8601`, Ausgabeformat `[.prettyPrinted,
            .sortedKeys]`.
        *   Sekundenbruchteile gehen dabei verloren. Tests vergleichen Daten
            deshalb auf ganze Sekunden.

#### 27. `ChorAssistent/Backup/BackupService.swift` (Create)

*   **Type / Scope:** `@MainActor enum BackupService`.
*   **`enum BackupError: LocalizedError`** mit deutschen Meldungen:

    | Fall | Meldung |
    |---|---|
    | `tooLarge` | „Datei größer als 5 MB" |
    | `unreadable` | „Datei nicht lesbar" |
    | `unknownVersion(Int)` | „Unbekannte Dateiversion <n>" |
    | `invalidSong(title: String, SongValidationError)` | „Lied ‚<Titel>' ungültig: <Grund>" |
    | `duplicateID` | „Doppelte ID in der Datei" |
    | `unknownSongID` | „Konzert verweist auf ein unbekanntes Lied" |
    | `saveFailed` | „Speichern fehlgeschlagen, Bibliothek unverändert" |

*   **`static func makeFile(context:) throws -> BackupFile`:**
    *   Alle Lieder und Konzerte.
    *   Konzerte werden über `orderedEntries` zu `songIDs`.
    *   Dazu die aktuellen Einstellungen.
*   **`static func writeExport(context:) throws -> URL`:**
    *   Schreibt nach `URL.temporaryDirectory`.
    *   Der Name ist `ChorAssistent-Sicherung-<yyyy-MM-dd>.json`, mit
        `DateFormatter` und Locale `en_US_POSIX`.
*   **`static var safetyBackupURL`:**
    `URL.documentsDirectory.appending(path: "Sicherung-vor-Import.json")`.
*   **`static func writeSafetyBackup(context:) throws`:** Schreibt
    `makeFile` mit `.atomic` an diese Stelle und überschreibt eine
    vorhandene Datei. Es gibt also immer nur die letzte.
*   **`static var hasSafetyBackup: Bool`.**
*   **`static func load(from url: URL) throws -> BackupFile`:**
    1.  `startAccessingSecurityScopedResource`, mit `defer stop…`.
    2.  Vor dem Lesen die Größe über `resourceValues(forKeys:
        [.fileSizeKey])` prüfen. Mehr als 5 000 000 Byte → `tooLarge`.
    3.  Lesen, dekodieren (bei einem Fehler `unreadable`), `validate`.
    4.  Die geprüfte Datei bleibt bis zur Bestätigung in `@State` der
        `SettingsView`.
*   **`static func validate(_ f: BackupFile) throws`:**
    *   Version ist bekannt.
    *   `Song.validate` für jedes Lied.
    *   Lieder-IDs und Konzert-IDs sind eindeutig.
    *   Jede `songID` ist bekannt.
*   **`static func replaceLibrary(with f: BackupFile, context: ModelContext)
    throws`.** Hier ist `context` der `mainContext`:
    1.  `let previous = context.autosaveEnabled`, dann
        `context.autosaveEnabled = false`. Am Ende per `defer` zurücksetzen.
    2.  Alle `Concert` per `fetch` holen und einzeln `delete` (die Einträge
        löscht `.cascade`). Dann alle `Song` einzeln `delete`. Es wird nie
        `delete(model:)` verwendet.
    3.  Lieder aus den DTOs mit ihren IDs anlegen. Konzerte anlegen und je
        `songID` einen `ConcertEntry` erzeugen. Danach
        `renumber(orderedEntries:)` in Dateireihenfolge.
    4.  `try context.save()`. Bei einem Fehler: `context.rollback()`, dann
        `throw saveFailed`.
    5.  Nur bei Erfolg werden die Einstellungen übernommen:
        *   Gibt es `f.settings`, schreibt die App die Werte mit
            `PlaybackSettings.clamp` auf den zulässigen Bereich gesetzt nach
            UserDefaults.
        *   Fehlt der Block, bleiben die aktuellen Werte unverändert.
*   **`static func importReplacing(_ f: BackupFile, context:) throws`:**
    `writeSafetyBackup`, dann `replaceLibrary`.
*   **`static func undoLastImport(context:) throws`:**
    1.  `safetyBackupURL` lesen, dekodieren, `validate`.
    2.  `replaceLibrary` ohne neue Sicherung.
    3.  Bei Erfolg die Sicherungsdatei löschen. Danach ist der Knopf
        deaktiviert.

#### 28. `ChorAssistent/Views/Settings/SettingsView.swift` (Create)

*   **Type / Scope:** SwiftUI-Formular.
*   **Abschnitt „Wiedergabe":**
    *   `Slider` für die Tondauer (Bereich und Schrittweite aus Datei 12) und
        für die Pause. Beide über `@AppStorage` mit denselben Schlüsseln, der
        Wert steht daneben, z. B. „1,0 s".
    *   Knopf „Hörprobe": `tonePlayer.play([60, 64, 67], sourceID:
        "hoerprobe")`.
*   **Abschnitt „Sicherung":**
    *   **Export, zweistufig:**
        *   „Sicherung erstellen" ruft `writeExport` auf und speichert die
            URL in `@State`.
        *   Danach erscheint darunter `ShareLink("Sicherung teilen", item:
            url)`.
        *   Fehler erscheinen in einem `alert`.
    *   **Import:** „Importieren" öffnet `fileImporter(allowedContentTypes:
        [.json])`, dann folgt `load`.
        *   Bei einem Fehler: `alert` mit `localizedDescription`.
        *   Sonst ein `confirmationDialog` mit genau dem Text aus der
            Spezifikation: „Die Datei vom <dd.MM.yyyy aus exportedAt> enthält
            <n> Lieder und <m> Konzerte. Deine aktuelle Bibliothek mit <x>
            Liedern und <y> Konzerten wird ersetzt."
        *   Bestätigen ruft `importReplacing` auf.
    *   **„Letzten Import rückgängig machen":** deaktiviert, wenn
        `!hasSafetyBackup`. Ohne Rückfrage wird `undoLastImport` aufgerufen.
*   **Abschnitt „Info":**
    *   Version aus `CFBundleShortVersionString`.
    *   Link „Lizenzen" öffnet `LicensesView` (in derselben Datei). Sie zeigt
        `ThirdPartyLicenses.txt` als `Text` in einer `ScrollView`.

#### 29. `ChorAssistent/Views/Shared/StartupErrorView.swift` (Create)

*   **Type / Scope:** SwiftUI.
*   **Proposed Changes:** Zeigt „Datenbank konnte nicht geöffnet werden" und
    darunter den Fehlertext. Wird nur aus Datei 6 benutzt.

**Prüfpunkt 6:** Die Tests in T5 laufen durch. Auf dem iPhone wurde
Prüfschritt M9 (CUJ 5 und Rückgängig) bestanden.

### Phase 7: Ablaufanzeige der Signatur (G9)

#### 30. `ChorAssistent/Support/ProvisioningInfo.swift` (Create)

*   **Type / Scope:** Reine Logik. Das ist inoffizielles Auslesen und darf
    nie abstürzen.
*   **Proposed Changes:** `enum ProvisioningInfo` mit:
    *   **`static func expirationDate(fromProfileData data: Data) -> Date?`:**
        1.  Daten als `String(decoding: data, as: UTF8.self)` lesen. Die
            signierte Hülle ist binär, die eingebettete plist ist ASCII.
        2.  Den Bereich von `<?xml` bis einschließlich `</plist>` suchen.
        3.  `PropertyListSerialization.propertyList` → Wörterbuch →
            `["ExpirationDate"] as? Date`.
        4.  Bei jedem Fehlschlag `nil`.
    *   **`static func expirationDate(bundle: Bundle = .main) -> Date?`:**
        lädt `embedded.mobileprovision` aus dem Bundle. Fehlt die Datei,
        gibt sie `nil` zurück.
    *   **`static func daysRemaining(until: Date, now: Date) -> Int`:**
        `max(0, Int(floor(until.timeIntervalSince(now) / 86_400)))`.

#### 31. `ChorAssistent/Views/Concerts/SignatureStatusView.swift` (Create)

*   **Type / Scope:** SwiftUI.
*   **Proposed Changes:**
    *   **Anzeige:**
        *   Zeigt „Signatur gültig: noch <n> Tage".
        *   Bei `n < 2` steht der Text rot: „Signatur läuft in <n> Tag(en)
            ab – vor dem nächsten Konzert neu installieren".
        *   Bei `nil` ist die Ansicht leer.
    *   **Einbindung:**
        *   oben in `ConcertListView` (Datei 22)
        *   in `RootTabView` (Datei 17) ein einmaliger `alert` beim
            App-Start, wenn `n < 2`
    *   Das Ablaufdatum wird einmal beim App-Start gelesen und als Wert in
        die Umgebung gegeben.

**Prüfpunkt 7:** Die Tests in T6 laufen durch. Auf dem iPhone zeigt
der Reiter „Konzerte" die Resttage an (Prüfschritt M10).

### Phase 8: Ressourcen, Dokumentation, Abschluss

#### 32. `ChorAssistent/Resources/Piano.sf2` (Create)

*   **Type / Scope:** Klangdatei aus Phase 0.
*   **Proposed Changes:** Im App-Target unter „Copy Bundle Resources"
    eintragen. Das wird schon ab Phase 3 gebraucht und in Phase 3
    hinzugefügt.

#### 33. `ChorAssistent/Resources/ThirdPartyLicenses.txt` (Create)

*   **Type / Scope:** Lizenztext als reiner Text.
*   **Proposed Changes:** Quelle (URL), Name „Upright Piano KW", Version
    laut Seite, Lizenz CC0 1.0 und der vollständige Lizenztext aus dem
    Archiv.

#### 34. `README.md` (Create)

*   **Type / Scope:** Projektdokumentation.
*   **Proposed Changes:**
    *   Zweck der App.
    *   Voraussetzungen: dauerhafter Mac, Xcode 16, iOS 17.
    *   Bauen und auf dem iPhone installieren.
    *   **Regel „am Vortag jedes Konzerts neu installieren"** und als Notfall
        ein Bildschirmfoto der Konzertliste.
    *   Wie man die SoundFont beschafft und prüft (Phase 0).
    *   Die Befehle aus dem Prüfplan.

**Prüfpunkt 8:** Der gesamte Prüfplan ist bestanden.

### Tests

Alle Testdateien verwenden Swift Testing (`import Testing`, `@Test`,
`#expect`). Model-Tests verwenden einen `ModelContainer` mit
`ModelConfiguration(isStoredInMemoryOnly: true)`.

**`ChorAssistentTests/TestSupport.swift`** (Create) enthält die gemeinsamen
Hilfen:
*   `TestStore`: eine In-Memory-Datenbank mit `addSong` und `addConcert`.
*   `makeTestDefaults()`: eigene UserDefaults pro Test.
*   `temporaryFileURL()`: eine temporäre Datei-URL.

#### T1. `ChorAssistentTests/NoteNameTests.swift` (Create)

*   **`name(midi:)`:** 60 → „C4", 69 → „A4", 70 → „B4", 71 → „H4", 66 →
    „Fis4", 36 → „C2", 84 → „C6".
*   **`pickerLabel`:** alle 12 Labels, insbesondere 1 → „Cis/Des", 10 → „B (=
    B♭)", 11 → „H (= B)".
*   **Hin und zurück:** `midi(components(x)) == x` für alle x in 36…84.

#### T2. `ChorAssistentTests/PlaybackScheduleTests.swift` (Create)

*   **3 Töne mit 1000/150 ms:** Start bei 0, 1150, 2300 und Stopp bei 1000,
    2150, 3300.
*   **Leere Liste:** ergibt keine Ereignisse.
*   **Pause 0:** Für alle i gilt `stop[i].timeMs <= start[i+1].timeMs`.
*   **Gleicher Ton zweimal mit Pause 0:** Bei gleicher Zeit steht `stop` vor
    `start`.

#### T3. `ChorAssistentTests/ConcertOrderingTests.swift` (Create)

*   **Durchnummerieren:** Nach jedem Schritt gilt `positions == Array(0..<n)`
    und die erwartete Titelreihenfolge stimmt:
    *   `append` ×4
    *   `move(fromOffsets: [0], toOffset: 3)`
    *   `remove(atOffsets: [1])`
    *   `LibraryActions.delete` auf ein Lied, das zweimal im Konzert steht.
        Beide Einträge müssen danach weg sein.
*   **Stabile Reihenfolge:** Bei absichtlich gleichen Positionen sortiert
    `orderedEntries` nach `id`. Zwei Aufrufe liefern dieselbe Reihenfolge.

#### T4. `ChorAssistentTests/SongValidationTests.swift` (Create)

*   **Ein Fall je Fehler:**
    *   leerer Titel bzw. Titel nur aus Leerzeichen
    *   0 Töne
    *   9 Töne
    *   Ton 35 und Ton 85
*   **Gültige Grenzwerte:** 1 Ton, 8 Töne, 36, 84.

#### T5. `ChorAssistentTests/BackupServiceTests.swift` (Create)

*   **Hin und zurück:**
    1.  Bibliothek mit doppeltem Eintrag und Notizen anlegen.
    2.  `makeFile`, dann `replaceLibrary` auf einen leeren Container.
    3.  Prüfen: Gleich sind IDs, Titel, `memo`, `pitches`, die Reihenfolge
        der Lied-IDs je Konzert und `createdAt` auf die Sekunde genau.
*   **Ungültige Dateien:** Es gibt je einen Test für `unknownVersion`,
    `invalidSong` (Ton 20, 9 Töne, leerer Titel), `duplicateID` und
    `unknownSongID`. Die bestehende Bibliothek bleibt jeweils unverändert.
*   **Größe:** Eine Datei mit 5 000 001 Byte ergibt `tooLarge`.
*   **Einstellungen:**
    *   Werte außerhalb der Grenzen werden auf den Bereich gesetzt.
    *   Fehlt der Block, bleiben die vorherigen Werte erhalten. Der Test
        nutzt eine eigene `UserDefaults(suiteName:)`, und `PlaybackSettings`
        bekommt dafür einen Parameter `defaults` mit dem Standardwert
        `.standard`.
*   **Sicherung und Rückgängig:**
    *   `importReplacing` schreibt die Sicherung. Ein zweiter Import
        überschreibt sie.
    *   `undoLastImport` stellt die Bibliothek vor dem Import wieder her und
        löscht danach die Sicherung.

#### T6. `ChorAssistentTests/ProvisioningInfoTests.swift` (Create)

*   **Fixture:** Ein `Data`-Wert aus Binärbytes, darin eine plist mit
    `ExpirationDate`, danach wieder Binärbytes. Erwartet wird das richtige
    Datum.
*   **Fehlerfälle:** keine plist bzw. kaputte plist → `nil`.
*   **`daysRemaining`:**
    *   47 h → 1
    *   48 h → 2
    *   Vergangenheit → 0

### Verification Plan

*   **Compilation/Build:**
    `xcodebuild -project ChorAssistent.xcodeproj -scheme ChorAssistent
    -destination 'generic/platform=iOS Simulator' build`. Erwartet: ohne
    Warnungen.
*   **Unit-Tests und Abdeckung:**
    `xcodebuild -project ChorAssistent.xcodeproj -scheme ChorAssistent
    -destination 'platform=iOS Simulator,name=<Simulator>'
    -enableCodeCoverage YES -resultBundlePath build/Tests.xcresult test`.
    *   Den Simulatornamen liefert `xcrun simctl list devices available`.
    *   Alle Tests in den T1–T6 müssen bestehen.
*   **Abdeckung:** `xcrun xccov view --report build/Tests.xcresult`.
    Mindestens 90 % Zeilenabdeckung für `Models/`, `Music/`,
    `Audio/PlaybackSchedule.swift`, `Backup/` und
    `Support/ProvisioningInfo.swift`. Oberfläche, `TonePlayer` und
    `AudioRouteMonitor` werden von Hand geprüft.
*   **Lint:** `swift format lint --strict --recursive ChorAssistent
    ChorAssistentTests`. Erwartet: Exit-Code 0.
*   **Von Hand, auf dem iPhone, nicht im Simulator:**
    *   **M1** CUJ 1 durchgehen.
    *   **M2** CUJ 2 bei eingeschaltetem Stummschalter: Die Töne sind hörbar.
        Läuft gleichzeitig Musik aus einer anderen App, spielt sie weiter.
    *   **M3** Stimmung prüfen: MIDI 36, 45, 48, 57, 60, 69, 72, 81 und 84
        einzeln abspielen und mit einem Stimmgerät messen, jeweils ±3 Cent
        gegenüber A4 = 440 Hz.
    *   **M4** CUJ 3 durchgehen.
    *   **M5** CUJ 4 durchgehen. Den Konzertmodus 5 Minuten ohne Berührung
        offen lassen: Der Bildschirm bleibt an. Nach „Beenden" sperrt er sich
        wieder gemäß der Einstellung „Automatische Sperre".
    *   **M6** Im Konzertmodus einen Anruf annehmen und beenden bzw. kurz in
        eine andere App wechseln. Danach bleibt der Bildschirm an, und
        „Abspielen" ist hörbar.
    *   **M7** Im Konzertmodus Kopfhörer bzw. Bluetooth verbinden und
        trennen: Die Anzeige des Ausgabegeräts wechselt, und „Abspielen"
        bleibt hörbar. Lautstärke unter 30 %: Die Warnung erscheint.
    *   **M8** Antippen von „Lied n von N" springt zu einem gewählten Lied.
        Über den Flugmodus prüfen, dass alles ohne Netzwerk funktioniert
        (G6).
    *   **M9** CUJ 5: Export, Import auf einem frisch installierten Gerät,
        Rückfrage mit den richtigen Zahlen, dann „Letzten Import rückgängig
        machen".
    *   **M10** Der Reiter „Konzerte" zeigt die verbleibenden Tage der
        Signatur.
    *   **M11** Latenz: Mit einem zweiten Gerät in Zeitlupe filmen. Vom
        Antippen bis zum Ton am eingebauten Lautsprecher vergehen höchstens
        100 ms (G3).
    *   **M12** Unter Einstellungen › Entwickler „Mediendienste
        zurücksetzen" auslösen, falls verfügbar. Danach ist „Abspielen"
        hörbar.

--------------------------------------------------------------------------------

<!-- Provenance: Indicates initial structural drafting via EGM. -->

*Drafted with EGM*
