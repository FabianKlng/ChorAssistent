# Stufe 7 – Kritik-Prüfung, Runde 1: chor-assistent.md

*   **Ziel:** `docs/designs/chor-assistent.md`, FeatureRange Zeilen 1–532
*   **Prüfer:** `egm-design` (feature-spec-standard), `egm-structural`
    (feature-spec-standard), `egm-style` (ohne Standard). Alle drei sind
    gelaufen, keiner ist ausgefallen.
*   **Kontext:** drei gespeicherte Webseiten unter `review_context/`
*   **Datum:** 2026-11-15

| Prüfer | Blocker | Major | Nit |
|---|---|---|---|
| egm-design | 1 | 9 | 12 |
| egm-structural | 0 | 4 | 5 |
| egm-style | 0 | 9 | 23 |

Rundenstatus: **nicht sauber**, weil es Blocker und Major-Befunde gibt, die
noch nicht erledigt sind.

## Rohbefunde (IDs `<prüfer>-1-<n>`)

### egm-design

*   **design-1-1 🔴** Kostenlose Xcode-Signatur läuft nach 7 Tagen ab; App
    startet am Konzerttag nicht. Nicht in Risiken/Offenen Fragen. (Z. 96–97,
    178–181, 367, 453)
*   **design-1-2 🟡** Ablehnung von P1 (PWA) schwach: „Ton erst nach
    Berührung" betrifft hier jede Wiedergabe ohnehin; Speicherlöschung gilt kaum
    für installierte Web-Apps; Wake Lock wird unterstützt. Mac- und
    Signaturkosten des nativen Wegs nicht abgewogen. (Z. 380–389)
*   **design-1-3 🟡** Salamander-Link ist SFZ, nicht SF2; Größe, Speicher,
    CC-BY-Namensnennung nicht berücksichtigt; Annahmekriterien fehlen im
    Feature-Teil. (Z. 527–529, 263–266, 362)
*   **design-1-4 🟡** Prüfung nur von A4 beweist nicht die Stimmung aller
    Sample-Bereiche 36–84. (Z. 101–104, 362)
*   **design-1-5 🟡** Bildschirmsperre wird nach Rückkehr in den Vordergrund
    nicht wieder abgeschaltet. (Z. 311–314)
*   **design-1-6 🟡** Audio-Wiederherstellung verlässt sich auf
    Benachrichtigungen, die iOS nicht zuverlässig schickt;
    `mediaServicesWereReset` fehlt. (Z. 290–295, 364)
*   **design-1-7 🟡** Import mit SwiftData nicht sicher atomar (Batch-Delete,
    Autosave). (Z. 346–349)
*   **design-1-8 🟡** Falsche Audio-Ausgabe (vergessene AirPods) oder
    Lautstärke 0 fällt im Konzert still aus; Bluetooth-Ausweg widerspricht
    100 ms. (Z. 260–261, 365)
*   **design-1-9 🟡** Konzert-Bedienung: Wischen widerspricht A3, Beenden
    nicht spezifiziert, kein Sprung zu einem Lied nach versehentlichem
    Schließen. (Z. 303–310)
*   **design-1-10 🟡** Nur Kreuz-Namen (Cis, Dis …) zwingen beim Übertragen aus
    b-Tonarten (Es, As, Des) zum Umdenken – genau die Fehlerquelle aus dem
    Problem. (Z. 33–34, 59–61, 253–256)
*   **design-1-N1…N12 🟢** Picker-Bereich 36–95 vs. erlaubt 36–84;
    „einzige Absicherung" stimmt nicht (iCloud-Backup); Renumber nach Cascade
    unklar; „nicht übereinander" vs. Ausklingen; abgebrochener Task kann neuen
    Ton abschneiden; `.playback` ohne Mix stoppt Musik anderer Apps;
    Import-Prüfung unvollständig; Velocity 100 statt 127; SwiftData-Risiko vage;
    G1 ohne „Töne bearbeiten"; Überschriftenebenen; Begründungen teils nur
    Zielwiederholung.

### egm-structural

*   **structural-1-1 🟡** „Future Improvements"/„Additional Resources" sind H3
    und hängen damit unter „Alternatives Considered". (Z. 513–529)
*   **structural-1-2 🟡** Risiken ohne Sicherheit und Skalierung. (Z. 358–368)
*   **structural-1-3 🟡** „Rejected by author:" widerspricht der Einleitung,
    nach der die Gründe aus der Sitzung stammen. (Z. 372–376 ff.)
*   **structural-1-4 🟡** Salamander-Link ist SFZ, nicht ladbar; CC-BY-Pflicht
    nicht erwähnt. (Z. 527–529)
*   **structural-1-N5…N9 🟢** Sprachmix der Überschriften; Risiken schwer
    auffindbar; Diagramm ohne `NoteName`/`PlaybackSettings`/`PlaybackSchedule`,
    unklar, wo der Konzertmodus startet; D1-Begründung endet mit Folge statt
    Grund; Verweise zeigen aus der Spezifikation heraus.

### egm-style

*   **style-1-1 🟡** „Erzeugt den Klang selbst / keine Tonaufnahmen"
    widerspricht der SoundFont, die aus Aufnahmen besteht. (Z. 14–15, 80–81)
*   **style-1-2 🟡** „Erzeugte Töne … exakt gestimmt" (T1) widerspricht dem
    Stimmungsrisiko der SoundFont. (Z. 412–413)
*   **style-1-3 🟡** B/H-Schutz durch Anhören überbehauptet: ohne Referenz
    hört man keinen Halbton Fehler. (Z. 248–256, 368)
*   **style-1-4 🟡** G2 „ungültige Töne kann man nicht speichern" – Picker
    erlaubt bis MIDI 95. (Z. 52–54, 225, 253–255)
*   **style-1-5 🟡** Picker zweimal unterschiedlich beschrieben (3 Teile vs.
    2 Räder); Begriffe Notenname/Tonname/Ton/Note uneinheitlich. (Z. 52, 253)
*   **style-1-6 🟡** Feld `Song.note` liest sich wie Musiknote; „Noten" mal
    Partitur, mal Ton. (Z. 88, 218, 277, 285, 328)
*   **style-1-7 🟡** „Einzige Absicherung gegen Geräteverlust" stimmt nicht.
    (Z. 72–74, 456)
*   **style-1-8 🟡** 100-ms-Aussage ohne Messung als Tatsache formuliert.
    (Z. 266–269)
*   **style-1-9 🟡** Salamander als „SoundFont-Kandidat" irreführend (SFZ).
    (Z. 525–529)
*   **style-1-N10…N32 🟢** G1 ohne Töne bearbeiten; „kurz"/„groß" ohne Maß;
    Reihenfolge Weiter/Abspielen; „Lied 2 von 4" groß?; Wischen nicht in G5;
    Akteur viermal anders benannt; Wiederholungen; „dieser Wahl" ohne Bezug;
    „kaputte Daten"; Testbarkeit des Timings überbehauptet; Knopf „Probe";
    Pseudo-Syntax `loadSoundBankInstrument`; „sichtbarer Fehlerhinweis";
    „Konzertansicht"; ungrammatische Prüffrage Z. 340; Reihenfolge der Sätze
    zu Rollback; „Velocity 100"; SwiftData-Risiko vage; „Rejected by author"
    überflüssig; Superlative in Alternativen; „Kreuz-Schreibweise" mit B;
    Überschriftenebenen; unbelegte Problemaussagen.

Die vollständigen Begründungen und Lösungsvorschläge stehen in
`goldfish_review_report.md`.
