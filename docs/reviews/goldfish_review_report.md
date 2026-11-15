Status: resolved (Runde 1 – auto accept: 19 Fixes und die
mitkorrigierten Nits übernommen; Issue 10 ESCALATE offen; übrige Nits
DECLINE)

# Goldfish Annotated Review Report

**Target:** `docs/designs/chor-assistent.md` (Zeilen 1–532, FeatureRange) –
Stufe 7, Runde 1

Ähnliche Befunde aus den Berichten mehrerer Prüfer sind zusammengefasst. Die
ursprünglichen IDs stehen in `critic_report.md`. Die Zeilenangaben beziehen
sich auf den aktuellen Stand der Datei.

**Übersicht:** 20 zusammengefasste Befunde, davon 1 Blocker, 19 Major, dazu
der Nit-Block. Vorschläge: 19 PROPOSE FIX, 1 ESCALATE (Befund 10). Die meisten
Nits werden als DECLINE nur festgehalten. Ein Teil davon wird mitkorrigiert,
weil die Änderung trivial ist.

Ich habe den Entwurf selbst geschrieben. Bei keinem der Major-Befunde habe ich
einen Beleg gefunden, mit dem ich ihn zurückweisen (CONTEST) könnte.

--------------------------------------------------------------------------------

## Blocker

### [Issue 1] [`egm-design`, auch `egm-style`, Stufe 5] - Severity: Blocker
*   **Affected Scope:** Z. 96–97, 105–109, 178–181, 358–368 (Non-Goals, Open
    Questions, Rahmen, Risiken)
*   **Discrepancy Description:** Mit einer kostenlosen Apple-ID läuft die
    signierte App nach 7 Tagen ab und startet dann nicht mehr. Für das
    Neusignieren braucht man jedes Mal einen Mac. Weder die Risikotabelle noch
    die offenen Fragen erwähnen das.
*   **Rationale:** Die Kernaufgabe der App ist das Konzert (G5, CUJ 4). Ein
    Ausfall ohne Vorwarnung an genau diesem Tag ist der schlimmste Fehler, den
    die App haben kann.
*   ***AI Suggestion:*** PROPOSE FIX
*   ***Justification:*** Der Befund stimmt. Im Entwurf stand das nur im
    Implementierungsplan als „einplanen". Ob ein bezahlter Account angeschafft
    wird, entscheidet der Autor. Die Korrektur trägt deshalb nur die Frage, das
    Risiko und die Gegenmaßnahmen ins Dokument ein. Sie trifft die Entscheidung
    nicht.
*   ***Proposed Edit:***
    *   **Open Questions:** Neue Frage „Bezahlter Apple-Developer-Account
        (99 $/Jahr, Signatur 1 Jahr) oder kostenlose Apple-ID (Signatur 7
        Tage, Neuinstallation vom Mac vor jedem Konzert)?". Sie hängt mit der
        Mac-Frage zusammen. Ist beides nicht dauerhaft gegeben, wird die
        Plattformwahl neu geöffnet (siehe Issue 2).
    *   **Risiken:** Neue Zeile „Signatur abgelaufen → App startet im Konzert
        nicht → bezahlter Account; sonst Ablaufanzeige in der App (Resttage aus
        `embedded.mobileprovision`, Warnung beim Start eines Konzerts bei < 2
        Tagen) und Notfall-Text-Export des Konzerts (Titel und Notennamen)".
    *   **Goals:** Neues G9 „Ablaufwarnung und Konzert als Text teilen".
    *   **Rahmen:** Der Satz zur Installation verweist auf die neue offene
        Frage.

## Major

### [Issue 2] [`egm-design`] - Severity: Major
*   **Affected Scope:** Z. 380–389 (Alternative P1)
*   **Discrepancy Description:** Die Nachteile der PWA sind teils falsch:
    *   Ein Tipp vor dem Ton ist ohnehin immer nötig.
    *   Installierte Web-Apps sind von der Speicherlöschung kaum betroffen.
    *   Wake Lock wird unterstützt.

    Die Kosten des nativen Wegs (Mac, Signatur) wurden nicht abgewogen.
*   **Rationale:** Der Standard verlangt, dass jede Ablehnung auf einem
    konkreten Zielkonflikt beruht.
*   ***AI Suggestion:*** PROPOSE FIX
*   ***Justification:*** Die Nachteile habe ich in der Sitzung selbst
    formuliert, und zwei davon tragen nicht.
    *   **Wirklicher Nachteil:** Web Audio auf iOS folgt standardmäßig dem
        Stummschalter. G4 ist mit Web-Mitteln also nur über Umwege
        erreichbar, und deren Verhalten hängt von der iOS-Version ab.
    *   **Abwägung:** Die Ablehnung kann bestehen bleiben, aber mit diesem
        Grund und mit den Kosten des nativen Wegs daneben.
*   ***Proposed Edit:***
    *   **Cons von P1:** ersetzen durch „Web Audio folgt auf iOS
        standardmäßig dem Stummschalter (G4 nur über versionsabhängige
        Umwege); Klangdatei und Daten im Browser-Speicher".
    *   **Pros von P1:** ergänzen um „kein Mac, keine 7-Tage-Signatur".
    *   **Reason:** „… G4 ist nativ verlässlich erreichbar. Wird Issue 1
        ohne dauerhaften Mac und ohne bezahlten Account beantwortet, ist diese
        Ablehnung neu zu prüfen."

### [Issue 3] [`egm-design`, `egm-structural`, `egm-style`, Stufe 5] - Severity: Major
*   **Affected Scope:** Z. 101–104, 362, 515–529 (Open Questions, Risiken,
    Additional Resources)
*   **Discrepancy Description:** Der Link zu Salamander zeigt auf eine
    SFZ-Version. `AVAudioUnitSampler` kann SFZ nicht laden. Die offizielle
    SF2-Datei ist 296 MiB groß. Die CC0-Datei von FreePats ist „Upright Piano
    KW", entpackt 10 MiB. Die CC-BY-Namensnennung ist nicht eingeplant. Im
    Feature-Teil fehlen Annahmekriterien.
*   **Rationale:** Die offene Frage, die die Umsetzung blockiert, stützt sich
    auf falsche Angaben.
*   ***AI Suggestion:*** PROPOSE FIX
*   ***Justification:*** Ich habe die Angaben in der gespeicherten
    FreePats-Seite nachgeprüft. Sie stimmen.
*   ***Proposed Edit:***
    *   **Offene Frage SoundFont:** Annahmekriterien nennen: SF2-Format,
        entpackt höchstens 30 MB, Lizenz erlaubt Weitergabe, Stimmung geprüft
        (siehe Issue 4). Hauptkandidat ist „FreePats Upright Piano KW, small,
        SF2" (CC0, 10 MiB entpackt).
    *   **Additional Resources:**
        *   Salamander kennzeichnen als „ausgeschieden: SFZ bzw. SF2 mit 296
            MiB, CC-BY".
        *   Velocity Grand kennzeichnen als „Public Domain, nur 9 Samples".
    *   **Risiken:** Satz ergänzen: „Bei CC-BY Namensnennung unter
        Einstellungen › Lizenzen".
    *   **Hinweis:** Die Tabelle im Implementierungsplan (Schritt 0) liegt
        außerhalb dieses Bereichs und wird in Stufe 9 angeglichen.

### [Issue 4] [`egm-design`] - Severity: Major
*   **Affected Scope:** Z. 101–104, 362
*   **Discrepancy Description:** Es wird nur A4 geprüft. Eine SF2-Datei stimmt
    aber jeden Sample-Bereich einzeln.
*   **Rationale:** Die Anfangstöne für Bass und Sopran stammen aus anderen
    Samples als A4.
*   ***AI Suggestion:*** PROPOSE FIX
*   ***Justification:*** Der Befund stimmt.
*   ***Proposed Edit:*** An beiden Stellen „A4 prüfen" ersetzen durch „alle C
    und A von C2 bis C6 (MIDI 36, 45, 48, 57, 60, 69, 72, 81, 84) mit einem
    Stimmgerät prüfen, jeweils ±3 Cent".

### [Issue 5] [`egm-design`, Stufe 5 M3, Stufe 6 #2] - Severity: Major
*   **Affected Scope:** Z. 311–314 (Konzertmodus, Bildschirm)
*   **Discrepancy Description:** Kehrt die App aus dem Hintergrund zurück,
    wird die Bildschirmsperre nicht wieder abgeschaltet.
*   **Rationale:** Das verletzt G5 und CUJ 4. Drei Prüfer haben den Fehler
    unabhängig voneinander gefunden.
*   ***AI Suggestion:*** PROPOSE FIX
*   ***Proposed Edit:*** Den Punkt „Bildschirm" ersetzen durch: „Es gibt eine
    Regel an einer Stelle: Die Bildschirmsperre ist genau dann aus, wenn der
    Konzertmodus angezeigt wird **und** die App im Vordergrund aktiv ist. Die
    Konzertansicht wertet die Regel bei jedem Wechsel von Anzeige oder
    App-Zustand neu aus. Nach der Rückkehr aus dem Hintergrund ist die Sperre
    also wieder aus." Bei der Prüfung von Hand Schritt 5 um „App in den
    Hintergrund und zurück" ergänzen. Das liegt in Stufe 9.

### [Issue 6] [`egm-design`] - Severity: Major
*   **Affected Scope:** Z. 290–295, 364 (Unterbrechungen, Risiken)
*   **Discrepancy Description:** iOS meldet das Ende einer Unterbrechung
    nicht zuverlässig. `mediaServicesWereResetNotification` wird nicht
    behandelt.
*   **Rationale:** Der im Dokument selbst genannte Fehler „bleibt nach einem
    Anruf stumm" bleibt so möglich.
*   ***AI Suggestion:*** PROPOSE FIX
*   ***Proposed Edit:*** Den Punkt „Unterbrechungen" ergänzen:
    *   „Zusätzlich heilt sich jeder Aufruf von Abspielen selbst: Läuft die
        Engine nicht, aktiviert die App die Sitzung und startet die Engine
        neu, bevor sie Töne plant."
    *   „Behandelt wird auch der Neustart der Mediendienste
        (`mediaServicesWereReset`: Engine und Sampler neu aufbauen) und die
        Rückkehr in den Vordergrund."

### [Issue 7] [`egm-design`, Stufe 5 M6] - Severity: Major
*   **Affected Scope:** Z. 337–351 (Export und Import)
*   **Discrepancy Description:** Der Import ist mit SwiftData nicht sicher
    atomar: Ein Batch-Delete lässt sich nicht zurücknehmen, und Autosave kann
    Zwischenstände speichern. Außerdem gibt es kein Rückgängig für einen
    gültigen, aber älteren Import.
*   **Rationale:** Genau der Datenverlust, gegen den G7 schützen soll.
*   ***AI Suggestion:*** PROPOSE FIX
*   ***Proposed Edit:*** Im Absatz zum Import „in einem Durchgang … rollback()"
    ersetzen durch:
    1.  „Vor dem Ersetzen schreibt die App automatisch eine Sicherung der
        aktuellen Bibliothek in ihren Documents-Ordner. Sie hebt nur die
        jeweils letzte auf."
    2.  „Der Import läuft in einem eigenen Datenbank-Kontext ohne Autosave.
        Objekte werden einzeln gelöscht, nicht per Batch-Delete. Gespeichert
        wird einmal am Ende."
    3.  „Schlägt das Speichern fehl, verwirft die App den Kontext. Die
        Sicherung aus Schritt 1 lässt sich über ‚Letzten Import rückgängig
        machen' wieder einspielen."

### [Issue 8] [`egm-design`] - Severity: Major
*   **Affected Scope:** Z. 260–262, 365 (Audio-Sitzung, Risiken), G3
*   **Discrepancy Description:** Ist ein falsches Ausgabegerät aktiv (z. B.
    vergessene AirPods) oder ist die Lautstärke auf 0, bleibt es im Konzert
    still, ohne Hinweis. Der Ausweg über einen Bluetooth-Lautsprecher bringt
    100–300 ms Verzögerung und widerspricht damit G3.
*   ***AI Suggestion:*** PROPOSE FIX
*   ***Proposed Edit:***
    *   **Konzertmodus:** ergänzen um „zeigt das aktuelle Ausgabegerät
        (iPhone-Lautsprecher, Kopfhörer, Bluetooth) und warnt bei
        Medienlautstärke unter 30 %".
    *   **G3:** ergänzen um „gemessen am eingebauten Lautsprecher".
    *   **Risiken:** Die Zeile „Lautsprecher zu leise" anpassen: Ein
        Bluetooth-Lautsprecher ist möglich, verletzt aber die Grenze von
        100 ms.

### [Issue 9] [`egm-design`, Stufe 5 M4, `egm-style` N14] - Severity: Major
*   **Affected Scope:** Z. 300–316 (Konzertmodus), G5
*   **Discrepancy Description:**
    *   Das Wischen widerspricht der Ablehnung von A3.
    *   Das Beenden ist nicht beschrieben.
    *   Nach versehentlichem Schließen gibt es keinen Weg zurück zum
        aktuellen Lied außer N-mal „Weiter".
*   ***AI Suggestion:*** PROPOSE FIX
*   ***Proposed Edit:***
    *   **Wischen:** den Satz streichen. Es bleiben nur die drei Knöpfe.
    *   **Beenden:** ergänzen um „‚Beenden' oben links, mit Rückfrage".
    *   **Sprung zu einem Lied:** ergänzen um „Ein Tipp auf ‚Lied n von N'
        öffnet die Liste des Konzerts. Ein Tipp auf ein Lied springt
        dorthin." Damit lässt sich nach einem versehentlichen Schließen
        schnell weitermachen.
    *   **Nicht übernommen:** Den Index dauerhaft zu speichern übernehme ich
        nicht. Mit dem Sprung zum Lied ist es nicht nötig.

### [Issue 10] [`egm-design`, `egm-style` N30, Stufe 6 #1] - Severity: Major
*   **Affected Scope:** Z. 33–34, 59–61, 253–256 (Problem, G3a, Eingabe)
*   **Discrepancy Description:** Das Auswahlrad zeigt nur Kreuz-Namen (Cis,
    Dis, Fis, Gis) und dazu B. Chornoten in b-Tonarten schreiben Es, As und
    Des. Man muss also im Kopf umrechnen. Das ist genau die Fehlerquelle,
    die im Problem genannt ist. Die Bezeichnung „Kreuz-Schreibweise" ist
    falsch, weil B kein Kreuz-Name ist.
*   ***AI Suggestion:*** ESCALATE
*   ***Justification:*** Der Befund stimmt. Für die Lösung gibt es aber
    mehrere vertretbare Wege mit Folgen für die Bedienung. Das soll der Autor
    entscheiden, nicht ich:
    *   **(a) Doppelnamen in Auswahl und Anzeige:** „Cis/Des", „Dis/Es",
        „Fis/Ges", „Gis/As". Das Datenmodell bleibt gleich, die Anzeige wird
        dafür breiter.
    *   **(b) Schreibweise pro Ton speichern:** Neben der MIDI-Nummer wird
        gespeichert, ob der Ton als Kreuz oder als b geschrieben ist. Das
        braucht ein neues Feld im Datenmodell und im Export.
    *   **(c) Nur Kreuz-Namen, als Non-Goal festgehalten:** Die Begründung
        lautet dann, dass das Anspielen beim Eintragen hilft.

    Unabhängig von der Wahl wird „Kreuz-Schreibweise" durch „deutsche
    Halbtonnamen" ersetzt.
*   ***Proposed Edit:*** Erst nach der Entscheidung des Autors.

### [Issue 11] [`egm-style`, `egm-design` N1, Stufe 6 #1] - Severity: Major
*   **Affected Scope:** Z. 51–54, 222–225, 253–256 (G2, Datenmodell, Eingabe)
*   **Discrepancy Description:**
    *   G2 beschreibt drei Auswahlteile, die Eingabe beschreibt zwei Räder.
    *   Das Rad erlaubt Töne bis MIDI 95, erlaubt sind aber nur Töne bis 84.
    *   Die Folgerung „also nicht speichern" stimmt deshalb nicht.
*   ***AI Suggestion:*** PROPOSE FIX
*   ***Proposed Edit:*** G2 neu: „Ein Ton wird über zwei Auswahlräder gewählt:
    Tonname (12 Halbtöne) und Oktave. Das Rad bietet nur Töne von C2 bis C6 an
    (in Oktave 6 nur C). Freitext gibt es nicht. Zusätzlich prüft die App beim
    Speichern Anzahl und Bereich."

### [Issue 12] [`egm-style`] - Severity: Major
*   **Affected Scope:** Z. 13–15, 80–81 (Overview, Non-Goals)
*   **Discrepancy Description:** „Die App erzeugt den Klang selbst. Es gibt
    keine Tonaufnahmen" widerspricht der SoundFont, die aus aufgenommenen
    Samples besteht.
*   ***AI Suggestion:*** PROPOSE FIX
*   ***Proposed Edit:***
    *   **Overview:** „Der Klang kommt aus einer mitgelieferten Klavier-
        Klangdatei (SoundFont, aufgenommene Klavier-Samples). Der Nutzer nimmt
        selbst nichts auf."
    *   **Non-Goal:** „Keine eigenen Aufnahmen: kein Mikrofon, keine vom
        Nutzer aufgenommenen Audiodateien."

### [Issue 13] [`egm-style`] - Severity: Major
*   **Affected Scope:** Z. 410–413 (Alternative T1)
*   **Discrepancy Description:** Die Aussage „Erzeugte Töne … exakt gestimmt"
    widerspricht dem Stimmungsrisiko der SoundFont.
*   ***AI Suggestion:*** PROPOSE FIX
*   ***Proposed Edit:*** Reason T1: „Töne aus Notennamen sind über eine
    einmal geprüfte Klangdatei gestimmt (siehe Issue 4) und hängen nicht von
    einer eigenen Aufnahme ab."

### [Issue 14] [`egm-style`, Stufe 5 N5] - Severity: Major
*   **Affected Scope:** Z. 248–256, 368 (Schutz vor B/H-Verwechslung, Risiken)
*   **Discrepancy Description:** Ohne Vergleichston hört man eine Abweichung
    von einem Halbton nicht.
*   ***AI Suggestion:*** PROPOSE FIX
*   ***Proposed Edit:***
    *   **Schutz:** neu formulieren: „Im Auswahlrad stehen die beiden
        verwechslungsträchtigen Töne als ‚B (= B♭)' und ‚H (= B)'. Überall
        sonst bleibt die Anzeige deutsch. Das Anspielen beim Auswählen hilft
        nur, wenn man den Zielton im Ohr hat oder mit einem Instrument
        vergleicht."
    *   **Risiken:** die Gegenmaßnahme entsprechend anpassen.

### [Issue 15] [`egm-style`, Stufe 6 #10] - Severity: Major
*   **Affected Scope:** Z. 88, 218, 277, 285, 328 (Non-Goals, Datenmodell,
    Tonerzeugung, Exportformat)
*   **Discrepancy Description:** Das Feld `note` ist die Notiz, liest sich in
    einer Musik-App aber wie eine Musiknote. „Noten" bedeutet im Text mal
    Partitur, mal Ton.
*   ***AI Suggestion:*** PROPOSE FIX
*   ***Proposed Edit:***
    *   `note` wird überall zu `memo`: Tabelle, Exportformat und die
        Dateien 3 und 11 in Stufe 9.
    *   In Z. 277 und 285 „Note" bzw. „Noten" durch „Ton" bzw. „Töne"
        ersetzen.

### [Issue 16] [`egm-style`, `egm-design` N2] - Severity: Major
*   **Affected Scope:** Z. 70–74, 453–456 (G7, N1)
*   **Discrepancy Description:** „Die einzige Absicherung gegen
    Geräteverlust" stimmt nicht, denn iCloud- und Finder-Backups enthalten
    auch die App-Daten.
*   ***AI Suggestion:*** PROPOSE FIX
*   ***Proposed Edit:*** „Das ist die einzige Absicherung, die die App selbst
    anbietet. Ein iCloud- oder Finder-Backup des iPhones enthält die Daten
    ebenfalls, wenn es eingeschaltet ist."

### [Issue 17] [`egm-style`] - Severity: Major
*   **Affected Scope:** Z. 266–269
*   **Discrepancy Description:** Die Grenze von 100 ms wird als erreicht
    behauptet, ohne Messung.
*   ***AI Suggestion:*** PROPOSE FIX
*   ***Proposed Edit:*** „… soll die Grenze von 100 ms erreichbar sein (G3).
    Geprüft wird das mit einem Zeitlupenvideo am eingebauten Lautsprecher
    (Prüfplan)."

### [Issue 18] [`egm-structural`, `egm-style` N31, `egm-design` N11] - Severity: Major
*   **Affected Scope:** Z. 513–529
*   **Discrepancy Description:** „Future Improvements" und „Additional
    Resources" sind H3 und hängen damit unter „Alternatives Considered".
*   ***AI Suggestion:*** PROPOSE FIX
*   ***Proposed Edit:*** Beide Überschriften auf H2 heben.

### [Issue 19] [`egm-structural`] - Severity: Major
*   **Affected Scope:** Z. 358–368 (Risiken)
*   **Discrepancy Description:** In den Risiken fehlen Sicherheit und
    Skalierung, obwohl der Standard beides verlangt.
*   ***AI Suggestion:*** PROPOSE FIX
*   ***Proposed Edit:*** Zwei Zeilen ergänzen:
    *   **Sicherheit:** „Manipulierte oder sehr große Importdatei → Absturz
        oder unsinnige Daten → vollständige Prüfung vor jeder Änderung,
        Dateigröße höchstens 5 MB. Die App verarbeitet keine
        personenbezogenen Daten und hat keinen Netzwerkzugriff."
    *   **Skalierung:** „Bibliothek mit mehreren hundert Liedern → für die
        Datenmenge (unter 100 KB) unkritisch. Grenzen: 8 Töne pro Lied, 36–84
        decken übliche Chorlagen ab."

### [Issue 20] [`egm-structural`, `egm-style` N28, Stufe 6 #15] - Severity: Major
*   **Affected Scope:** Z. 372–376 und jede Zeile „Reason for Rejection"
*   **Discrepancy Description:** „Rejected by author:" klingt so, als hätte
    der Autor die Begründung selbst gegeben. Laut Einleitung stammt sie aber
    aus der Sitzung.
*   ***AI Suggestion:*** PROPOSE FIX
*   ***Justification:*** Die Entscheidung hat der Autor getroffen, die
    Begründung stammt aus den Fragen. Die Kennzeichnung soll beides
    auseinanderhalten.
*   ***Proposed Edit:*** Überall „Rejected by author:" ersetzen durch „Vom
    Autor abgelehnt. Nachteil laut Sitzung:".

## Nits

Diese Nits werden **mitkorrigiert (PROPOSE FIX)**, weil die Änderung
trivial ist:

*   **G1:** „Töne bearbeiten" ergänzen. Gefunden von style N10 und design N10.
*   „Halbton Abstand" wird zu „Halbtonabstand".
*   Knopf „Probe" heißt künftig „Hörprobe". Gefunden von style N20 und
    Stufe 6 #11.
*   Velocity 127 statt 100, also die größte Lautstärke, und ein deutscher
    Name dazu („Anschlagstärke"). Gefunden von design N8 und style N26.
*   Das SwiftData-Risiko wird allgemein formuliert: „Fehler in einem jungen
    Framework". Die Gegenmaßnahmen verweisen auf Issue 7 und die
    Export-Erinnerung. Gefunden von style N27 und design N9.
*   Die Prüffrage in Z. 340 wird grammatisch korrigiert. Die Liste wird um
    diese Prüfungen ergänzt: „keine doppelten IDs", „Titel nicht leer",
    „Dateigröße". Gefunden von style N24, design N7 und Stufe 6 #8.
*   Fehlt im Import der Block `settings`, bleiben die aktuellen Einstellungen
    erhalten. Gefunden in Stufe 6 #9.
*   „Konzertansicht" heißt künftig `ConcertEditView`, und das Diagramm wird
    angepasst. Gefunden von style N23 und structural N7.
*   „Dieser Wahl" in Z. 230 wird zu „ConcertEntry mit `position` statt
    Array (siehe R1)". Gefunden von style N17 und Stufe 6 #7.
*   CUJ 2 „nicht übereinander" wird zu „ein neuer Ablauf beginnt erst, wenn
    der alte gestoppt ist; das kurze Ausklingen des Klaviers ist erlaubt".
    Gefunden von design N4.
*   Audio-Sitzung `.playback` mit `.mixWithOthers`, damit Musik anderer Apps
    nicht stoppt. Der Stummschalter wird trotzdem ignoriert. Gefunden von
    design N6.

Diese Nits werden **nur festgehalten (DECLINE)**:

*   design N3 und N5: Durchnummerieren nach Cascade sowie Generation-Token.
    Das betrifft den Implementierungsplan und gehört zu Stufe 9.
*   Sprachmix der Überschriften (structural N5): Die Vorlage gibt englische
    H2-Überschriften vor.
*   „Risiken" als H2 (structural N6).
*   Diagramm ohne `NoteName` und `PlaybackSettings` (structural N7, Teil 1).
*   Die D1-Begründung endet mit einer Folge statt einem Grund (structural N8).
*   Verweise auf Schritt 0 (structural N9): Das erledigt sich mit Issue 3.
*   „Kurz" und „groß" ohne Maß, Reihenfolge Weiter/Abspielen, „Lied 2 von 4"
    (style N11–N13).
*   Akteur vier Mal anders benannt, Wiederholungen, „kaputte Daten",
    Testbarkeit des Timings, Pseudo-Syntax, „sichtbarer Fehlerhinweis",
    Satzreihenfolge zu Rollback (style N15, N16, N18, N19, N21, N22, N25):
    Teils erledigt durch Issue 7.
*   Superlative in den Alternativen, unbelegte Problemaussagen (style N29,
    N32).
*   Begründungen, die nur ein Ziel wiederholen (design N12).
