# Stufe 8 – Zwischen-Zoom-Out: chor-assistent.md

*   **Ziel:** `docs/designs/chor-assistent.md`, ganze Datei (Zeilen 1–1001)
*   **Prüfer:** `egm-zoom-out`, in frischem Kontext. Er hat
    `zoom_out_report.md` und `goldfish_review_report.md` zum Vergleich gelesen.
*   **Datum:** 2026-11-15
*   **Gesamturteil:** Änderungen nötig. Kein Blocker, 4 Major, 6 Nit.

Der Prüfer hat Abweichungen bewusst übergangen, die nur entstehen, weil der
Implementierungsplan noch nicht angepasst ist. Betroffen sind die Tabelle in
Schritt 0, `note`/`memo`, das Wischen in Datei 21, `onAppear`, „Probe" und die
Prüfung nur von A4. Diese Punkte gehören zu Stufe 9.

## Stand der Major-Befunde aus Stufe 5

| Stufe 5 | Stand |
|---|---|
| M1 Signatur | erledigt: offene Frage, Risiko, G9. G9 wird aber unten als Major neu bewertet. |
| M2 ConcertEntry/position | **offen.** Es ist weder dem Autor vorgelegt noch im Dokument festgehalten. |
| M3 Bildschirmsperre | erledigt (Z. 361–366) |
| M4 Wischen | erledigt (Z. 356) |
| M5 SoundFont-Fakten | erledigt und gegen die gespeicherten Seiten geprüft (Z. 113–123, 606–614) |
| M6 Datenschutz durch Disziplin | **halb erledigt:** Sicherung vor dem Import und Rückgängig sind drin; Erinnerung und `lastExportedAt` fehlen. |

## Major

### Z8-M1 – `ConcertEntry` mit `position`: Die Entscheidung fehlt, und die Kosten sind gestiegen

*   **Stellen:** Z. 228, 241–266, 390–392, 411–413, 434, 580–590, 601–602
*   **Problem:** Der Grund gegen R1 ist weiter nur ein künftiger Bedarf. Die
    Future Improvements sagen es offen: „wird durch `ConcertEntry`
    vorbereitet". Seit Stufe 5 sind Import und Rückgängig dazugekommen, und
    beide müssen Einträge über `renumber` neu aufbauen. Der Export speichert
    die Reihenfolge schon als `songIDs`. Damit gibt es zwei Darstellungen der
    Reihenfolge, die bei jedem Export, Import und Rückgängig ineinander
    übersetzt werden müssen.
*   **Empfehlung:** Den Autor ausdrücklich entscheiden lassen:
    *   **Möglichkeit 1:** `Concert.songIDs: [UUID]`, oder `Slot { id, songID }`,
        falls später Daten pro Platz gebraucht werden. Damit fallen
        `ConcertEntry`, `position`, `renumber`, die Risikozeile und Testdatei 28
        weg.
    *   **Möglichkeit 2:** `ConcertEntry` bewusst behalten. Dann muss die
        Begründung bei R1 das sagen, und der Satz in den Future Improvements
        fällt weg.

### Z8-M2 – Die Frage zu Vorzeichen-Namen (Issue 10) fehlt im Dokument

*   **Stellen:** Z. 31–35, 62–64, 104–105, 276–287
*   **Problem:** Die Frage ist im Bericht zum Klärungsschritt als ESCALATE
    offen. Im Dokument steht sie aber nirgends. Wer das Dokument liest, hält
    das Design deshalb für fertig. Sie betrifft genau die Fehlerquelle aus
    dem Problem.
*   **Empfehlung:** Sofort als offene Frage aufnehmen. Die einfachste Lösung
    ist (a), beschränkt auf das Auswahlrad: „Cis/Des", „Dis/Es", „Fis/Ges",
    „Gis/As". Das läuft über denselben Mechanismus wie die Labels „B (= B♭)"
    und „H (= B)". Am Datenmodell ändert sich nichts.

### Z8-M3 – G9 schützt das Konzert nicht so, wie es beschrieben ist

*   **Stellen:** Z. 83–87, 129–134, 369–374, 431
*   **Problem:**
    1.  G9 ergibt nur bei einer kostenlosen Apple-ID Sinn. Diese Frage ist aber
        noch offen.
    2.  Die Warnung erscheint beim Start eines Konzerts. Am Tag, an dem die
        Signatur wirklich abläuft, startet die App gar nicht. Es kann dann
        also keine Warnung erscheinen, und im Konzert ist kein Mac zur Hand.
    3.  „Als Text teilen" hilft nur, wenn man es **vorher** gemacht hat. Ein
        Bildschirmfoto der Konzertliste leistet dasselbe ohne Code.
    4.  `embedded.mobileprovision` zu lesen heißt, eine signierte Datei selbst
        zu zerlegen. Das ist eigener Code nur für die Installation zum
        Entwickeln.
*   **Empfehlung:**
    *   Zuerst die Frage zum Apple-Account klären.
    *   **Bei bezahltem Account:** die Ablaufwarnung streichen.
    *   **Bei kostenloser Apple-ID:** die Resttage beim App-Start bzw. im
        Reiter „Konzerte" anzeigen, nicht erst beim Start des Konzerts. Dazu
        die Regel „am Vortag jedes Konzerts neu installieren" in die
        Risikotabelle.
    *   **„Als Text teilen":** ersetzen durch „vorher ein Bildschirmfoto der
        Liste machen" oder ausdrücklich „vor dem Konzert" dazuschreiben.

### Z8-M4 – Stufe 5 M6 ist nur halb erledigt, und der Klärungsbericht ist ungenau

*   **Stellen:** Z. 74–80, 243, 386, 437
*   **Problem:** Eine Erinnerung an den Export gibt es nicht. `updatedAt` wird
    gespeichert und exportiert, aber nirgends gelesen.
*   **Anmerkung von mir (Elephant):** Der Prüfer hat recht. In
    `goldfish_review_report.md` habe ich bei den mitkorrigierten Nits
    geschrieben, die Risikozeile verweise auf „die Export-Erinnerung". Das
    stimmt nicht. Die Risikozeile im Dokument nennt nur Export, die Sicherung
    vor dem Import und Tests. Eine Erinnerung wurde nie aufgenommen. Der
    Fehler steckt also im Bericht, nicht im Dokument.
*   **Empfehlung:** Ausdrücklich entscheiden:
    *   **Einfacher:** keine Erinnerung. Die Risikozeile nennt das
        Geräte-Backup als Gegenmaßnahme, und `updatedAt` fällt weg.
    *   **Sonst:** eine Erinnerung in einem Satz beschreiben. Sie wäre dann
        die einzige Stelle, die `updatedAt` liest.

## Nit

*   **Z8-N1 – Zwei Modelle für das Timing (Stufe 5 N1, offen), Z. 304–313:**
    `play` berechnet einen `PlaybackSchedule`, und die Schleife benutzt ihn
    danach nicht. Eines der beiden Modelle wählen.
*   **Z8-N2 – Drei Wege zum Neustart der Engine, Z. 325–337:** Eine einzige
    Zuständigkeit `ensureRunning()` beschreiben, die jeder Auslöser aufruft.
*   **Z8-N3 – Wieder mehr API-Details im Technischen Plan (Stufe 5 N3, mehr
    geworden):** Hier nur Zuständigkeiten und Garantien nennen. Die Mechanik
    gehört in den Implementierungsplan.
*   **Z8-N4 – Rückgängig soll vorhandene Wege nutzen, Z. 409–419:** Die
    Sicherung schreibt die vorhandene Export-Funktion. Rückgängig ist
    `replaceLibrary` auf diese Sicherung, ohne Rückfrage und ohne neue
    Sicherung.
*   **Z8-N5 – Sprung-Liste, Z. 357–360:** Die Begründung „versehentlich
    geschlossen" trägt kaum, weil das Beenden schon eine Rückfrage hat.
    Begründen mit „App wurde beendet oder neu gestartet". Die Fläche für
    „Lied n von N" darf nicht neben „Abspielen" liegen.
*   **Z8-N6 – Herkunft der Ersatz-SoundFont, Z. 612–614:** Ergänzen:
    „Herkunft der Samples ungeklärt". Polyphone nennt als Quelle „Piano set
    (Stephane Bernard)", und für den Download braucht man ein Konto.

## Ohne Befund

Diese Änderungen hat der Prüfer als angemessen und dem Hauptziel dienlich
bestätigt:

*   die Regel für die Bildschirmsperre
*   die Anzeige des Ausgabegeräts und die Warnung bei niedriger Lautstärke
*   die Selbstheilung beim Abspielen und die Behandlung eines
    Medien-Neustarts, unter dem Vorbehalt von Z8-N2
*   die korrigierten Annahmekriterien für die SoundFont
*   die neu formulierte Ablehnung der PWA
*   die Risikozeilen zu Sicherheit und Skalierung
*   das Streichen der Wischgesten
