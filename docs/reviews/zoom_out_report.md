# Stufe 5 – Zoom-Out-Prüfung: chor-assistent.md

*   **Ziel:** `docs/designs/chor-assistent.md` (Zeilen 1–916)
*   **Prüfer:** `egm-zoom-out`, `egm-inventive-catalyst` (beide in frischem
    Kontext, ohne Kenntnis der Entwurfssitzung)
*   **Kontext:** drei gespeicherte Webseiten unter `review_context/`
*   **Datum:** 2026-11-15
*   **Gesamturteil:** Änderungen nötig. Kein Blocker, 6 Major, 6 Nit (nach
    Zusammenführen doppelter Befunde).

Die Faktenbehauptungen zur SoundFont (Befund M5) habe ich direkt in
`review_context/freepats-acoustic-grand-piano.html` nachgeprüft. Sie stimmen.

--------------------------------------------------------------------------------

## Major

### M1 – Die 7-Tage-Signatur kann die App am Konzerttag lahmlegen

*   **Gefunden von:** beiden Prüfern
*   **Stellen:** Offene Fragen (Z. 105–109), Schritt 0.1 (Z. 541–544), Risiken
    (Z. 367), Alternative P1 (Z. 380–389)
*   **Problem:** Ohne bezahlten Apple-Account läuft die App 7 Tage. Für jede
    Neuinstallation braucht man einen Mac, und es ist noch offen, ob überhaupt
    einer zur Verfügung steht. Dann braucht man jede Woche einen Mac, solange
    die App genutzt wird. Läuft die Signatur ab, startet die App nicht, und die
    App selbst warnt vorher nicht. Das Dokument verlangt nur „einplanen". In der
    Risikotabelle fehlt dieser Fall ganz. Die Webapp (P1) wurde aus
    Zuverlässigkeitsgründen verworfen. Gegen diese neue Unzuverlässigkeit wurde
    sie nie abgewogen.
*   **Empfehlungen:**
    1.  „Bezahlter Apple-Account ja/nein" als eigene Entscheidung neben der
        Mac-Frage aufnehmen.
    2.  Eine Zeile in der Risikotabelle ergänzen: „Signatur abgelaufen → App
        startet im Konzert nicht".
    3.  Die App liest beim Start das Ablaufdatum aus `embedded.mobileprovision`.
        Sie zeigt die Resttage an und warnt beim Start eines Konzerts, wenn
        weniger als 2 Tage übrig sind.
    4.  Eine Notlösung: „Konzert als Text teilen", also Titel und Notennamen
        als Text. Damit kann man notfalls mit Stimmgabel oder Klavier arbeiten.
    5.  Gibt es weder dauerhaft einen Mac noch einen bezahlten Account, die
        Plattformentscheidung (P1) neu öffnen.

### M2 – `ConcertEntry` mit `position` ist vermeidbare Komplexität

*   **Gefunden von:** beiden Prüfern
*   **Stellen:** Datenmodell (Z. 214–238), Alternativen D1 (Z. 481–489) und R1
    (Z. 501–511), Future Improvements (Z. 522), Dateien 4–6, 12, 28
*   **Problem:** Das Dokument nennt `position` selbst „die bekannte
    Fehlerquelle". Um sie einzudämmen, braucht es mehrere Teile:
    *   die Regel, dass nur eine Funktion schreibt
    *   eine Sortierung mit zweitem Schlüssel und Nil-Filter
    *   ein erneutes Durchnummerieren nach jedem Löschen
    *   eine eigene Testdatei

    Der einzige Grund gegen R1 (`songIDs`) war „später Daten pro Eintrag". Das
    ist ein künftiger Bedarf, kein heutiger (YAGNI). Die Kosten, die R1
    angeblich hat, fallen ohnehin an:
    *   `LibraryActions.delete` ist schon eigener Code, der bei jedem Löschen
        über mehrere Modelle läuft.
    *   Der Konzertmodus behandelt schon gelöschte Lieder.
    *   Das Exportformat speichert Konzerte schon als `songIDs`.

    Das Design trägt so die Kosten von SwiftData **und** die eines
    selbstgebauten JSON-Formats.
*   **Empfehlungen (nach Größe des Eingriffs):**
    *   **(a)** SwiftData behalten, aber `Concert` speichert ein geordnetes
        Array. Das kann `songIDs: [UUID]` sein. Es kann auch ein kleines
        `Codable`-Struct `Slot { id, songID }` sein, das später Daten pro Platz
        erlaubt. Damit fallen `ConcertEntry`, `position`, `renumber` und die
        Positionstests weg.
    *   **(b)** Die JSON-Datei (D1) als Speicher neu erwägen: Speicher und
        Export sind dann ein Format mit einem Versionierungsweg.
*   **Hinweis:** Dieser Befund stellt eine ausdrückliche Entscheidung des
    Autors infrage (Konzert-Reihenfolge A, SwiftData). Ob er übernommen wird,
    entscheidet der Autor.

### M3 – Bildschirmsperre geht nach Rückkehr aus dem Hintergrund wieder an

*   **Gefunden von:** `egm-zoom-out`
*   **Stellen:** Konzertmodus (Z. 311–314), Datei 2 (Z. 578–579), Datei 21
    (Z. 801–802)
*   **Problem:** Die App setzt `isIdleTimerDisabled = false`, wenn sie in den
    Hintergrund geht. `ConcertPlayerView` setzt den Wert nur in `onAppear` auf
    `true`. `onAppear` läuft aber nicht erneut, wenn die App zurückkommt, etwa
    nach dem Kontrollzentrum, einer Mitteilung oder einem Anruf. Danach kann
    sich der Bildschirm mitten im Konzert sperren. Das verletzt G5.
*   **Empfehlung:** Die Regel an genau einer Stelle festlegen: `disabled =
    Konzertmodus offen && scenePhase == .active`. Sie wird in
    `ConcertPlayerView` über `.onChange(of: scenePhase)` ausgewertet. In die
    Prüfung von Hand kommt dazu: „App in den Hintergrund und zurück, Bildschirm
    bleibt an".

### M4 – Das Wischen im Konzertmodus widerspricht der eigenen Begründung

*   **Gefunden von:** beiden Prüfern (einmal Major, einmal Nit, hier als Major
    geführt)
*   **Stellen:** Konzertmodus (Z. 310), Datei 21 (Z. 799), Alternative A3
    (Z. 444–445)
*   **Problem:** A3 wurde abgelehnt, weil mehr Bedienelemente das Risiko von
    Fehlbedienung im Konzert erhöhen. Das Wischen ist ein zweiter, unsichtbarer
    Weg, das Lied zu wechseln. Bei einem Abspielknopf, der die halbe
    Bildschirmhöhe einnimmt, wechselt ein leicht verrutschter Tipp das Lied und
    stoppt den Ton. Kein Ziel und keine CUJ verlangt das Wischen.
*   **Empfehlung:** Das Wischen streichen. Nur die drei Knöpfe bleiben.

### M5 – Die Angaben in der SoundFont-Tabelle sind falsch

*   **Gefunden von:** beiden Prüfern. Ich habe die Angaben in der gespeicherten
    Seite nachgeprüft.
*   **Stellen:** Schritt 0 Tabelle (Z. 548–556), Additional Resources
    (Z. 527–529), Offene Fragen (Z. 101–104), Alternative K1
*   **Problem:**
    *   **FreePats:** Die CC0-Datei mit 5,8 MiB ist **„Upright Piano KW"**
        (ein Kawai-Klavier), kein Flügel. 5,8 MiB ist die gepackte Größe,
        entpackt sind es **10 MiB**. Die „vollständige Variante" mit 27 MiB
        ist entpackt **56 MiB** groß und verfehlt damit die Grenze von 30 MB.
    *   **Salamander:** FreePats bietet eine **offizielle** SF2 an. Sie ist
        **296 MiB** groß und scheidet damit an der Größengrenze aus.
    *   **Velocity Grand:** Die Polyphone-Seite selbst führt „public domain"
        als Lizenz.
    *   Damit gibt es tatsächlich nur einen brauchbaren Kandidaten. Das
        Dokument sagt das nicht.
*   **Empfehlung:**
    *   Die Tabelle korrigieren und entpackte Größen angeben.
    *   Hauptkandidat ist „Upright Piano KW, small" (CC0, 10 MiB). Ersatz ist
        die Variante „small, bright" (6,0/10 MiB).
    *   Salamander als ausgeschieden markieren.
    *   Weil CC0 keine Namensnennung verlangt, entfällt auch der „Preis" in der
        Begründung zu K1.
    *   Optional die Datei vor dem Einbinden auf C2–C6 kürzen. Das muss in
        `ThirdPartyLicenses.md` dokumentiert werden.

### M6 – Der Schutz der Daten hängt nur an der Disziplin des Nutzers

*   **Gefunden von:** `egm-inventive-catalyst`
*   **Stellen:** G7 (Z. 70–74), Non-Goal (Z. 95), Export/Import (Z. 337–351,
    708–712), Risiken (Z. 366)
*   **Problem:**
    1.  Gegen das Risiko „SwiftData-Fehler → Datenverlust" hilft nur
        „regelmäßiger Export". Die App erinnert aber nie daran und merkt sich
        auch nicht, wann zuletzt exportiert wurde.
    2.  Der Import ersetzt alles ohne Rückgängig-Funktion. Das Beispiel im
        Dokument selbst (24 Lieder ersetzen 27) zeigt genau den Fall, in dem 3
        Lieder endgültig verloren gehen.
*   **Empfehlungen:**
    *   Vor `replaceLibrary` speichert die App automatisch einen Schnappschuss
        der aktuellen Bibliothek im Documents-Ordner. Dazu kommt die Funktion
        „Import rückgängig machen". Der Export-Code existiert schon.
    *   Die App speichert `lastExportedAt` und zeigt einen Hinweis, wenn es
        Änderungen gibt, die seit X Tagen nicht exportiert wurden, z. B. beim
        Start eines Konzerts.
    *   Optional bleiben die letzten 3 automatischen Schnappschüsse erhalten
        und sind in der Dateien-App sichtbar (`UIFileSharingEnabled`).

--------------------------------------------------------------------------------

## Nit

### N1 – Zwei widersprüchliche Modelle für das Timing

*   **Stellen:** Z. 270–278 und Datei 8/9 (Z. 639–665), Datei 27
*   **Problem:** Der Technische Plan beschreibt eine Schleife: schlafen,
    stoppen, Pause. Datei 9 beschreibt das Schlafen bis zu Zeitpunkten aus dem
    vorab berechneten `PlaybackSchedule`. Ein eigener Typ samt Testdatei nur für
    `i · (d + g)` ist viel Struktur für eine Multiplikation.
*   **Empfehlung:** Ein Modell wählen und beide Stellen daran angleichen.

### N2 – `soundingNotes` von Hand statt „All Notes Off"

*   **Stellen:** Tonerzeugung (Z. 280–288), Datei 9
*   **Empfehlung:** `stop()` schickt MIDI CC 123 über
    `sampler.sendController(123, withValue: 0, onChannel: 0)`. Ob das
    funktioniert, auf dem Gerät prüfen. Als Rückfallweg eine Schleife über
    36–84.

### N3 – Code-Details im Technischen Plan

*   **Stellen:** Z. 230–238, 264–267, 275–278, 311–313
*   **Problem:** Signaturen, Bank-Parameter und `isIdleTimerDisabled` stehen im
    FeatureRange und noch einmal im Implementierungsplan.
*   **Empfehlung:** Im Technischen Plan nur Zuständigkeiten und Datenfluss
    beschreiben. Signaturen stehen nur im Implementierungsplan.

### N4 – Platzhalter „Lied gelöscht" für einen Zustand, der nicht eintreten kann

*   **Stellen:** Z. 803–804, Nil-Filter Z. 236, 599
*   **Problem:** Solange der Konzertmodus im Vollbild offen ist, lässt sich die
    Bibliothek nicht bearbeiten. `.cascade` entfernt die Einträge ohnehin.
*   **Empfehlung:** Den Platzhalter streichen oder das konkrete Szenario
    nennen, in dem er gebraucht wird. Mit M2 (a) erledigt sich das durch das
    Filtern beim Lesen.

### N5 – Die Schreibweise B/H wird nur über das Gehör abgesichert

*   **Stellen:** Z. 248–250, Risiken Z. 368
*   **Problem:** Das Anspielen hilft nur dem, der den Zielton schon im Ohr hat.
*   **Empfehlung:** Nur im Auswahlrad „B (= B♭)" und „H (= B)" beschriften.
    Dafür gibt es eine eigene Funktion `NoteName.pickerLabel`. Sonst bleibt die
    Anzeige überall deutsch, das Non-Goal bleibt also eingehalten.

### N6 – Ungenutzte Felder und überdimensionierte Prüfvorgaben

*   **Stellen:** `updatedAt`/`touch()` (Z. 218, 586, 590, 742, 328),
    Verification Plan (Z. 896–900)
*   **Problem:** `updatedAt` liest keine Stelle im Code. Die Abdeckung von
    90 % und das Lint-Gate ohne Befunde sind für eine App eines Einzelnen auf
    dem eigenen Gerät viel Prozess. Die echten Risiken deckt die Prüfung von
    Hand ab.
*   **Empfehlung:** `updatedAt` streichen. Ausnahme: M6 wird übernommen, dann
    braucht der Hinweis auf nicht exportierte Änderungen ein solches Signal,
    und zwar auch an `Concert`. Die Abdeckungsvorgabe und das Lint-Gate als
    optional kennzeichnen.

--------------------------------------------------------------------------------

## Ohne Befund

Diese Teile haben die Prüfer ausdrücklich ohne Befund bestätigt:

*   die vorgewärmte Audio-Engine für die Grenze von 100 ms
*   die Kategorie `.playback` gegen den Stummschalter
*   die Behandlung von Unterbrechungen und den Neustart der Engine
*   die vollständige Prüfung der Importdatei vor der Rückfrage
*   die Wahl der nativen App gegenüber PWA und Cross-Platform, unter dem
    Vorbehalt von M1
