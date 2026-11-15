# Stage 6 – Comprehension Test: chor-assistent.md

*   **Target:** `docs/designs/chor-assistent.md` (FeatureRange 1–532, DetailedRange 533–916)
*   **Reviewer:** `egm-comprehension` (fresh context, document only, no GoldfishContext)
*   **Date:** 2026-11-15
*   **Result:** No Blockers, 4 Major, 11 Nit. Every section could be paraphrased.

Complete reviewer result follows, unedited.

--------------------------------------------------------------------------------

**What this proposes**

The document proposes ChorAssistent, a native iPhone app that is used only offline and on one device. It is for the person who gives the starting notes to a choir. Each song is stored with a title, an optional short note and an ordered list of 1–8 pitches, kept as MIDI numbers from 36 to 84. The app shows these pitches with German note names (B = B♭, H = B). Tapping "Abspielen" plays the pitches one after another, with a built-in piano SoundFont as the sound source. Tone length and the gap between tones are global settings. Playback must start within 100 ms and must be audible even when the mute switch is on.

Concert lists are ordered sequences of library songs, and a song may appear more than once. A full-screen concert mode steps through a list with large Back, Play and Next buttons and keeps the screen from locking. Backup is one JSON export file. Importing it replaces the whole library after the file has been checked and the user has confirmed.

The detailed plan lists about 30 files: SwiftData models (Song, Concert, ConcertEntry), a single `renumber` function that is the only writer of positions, a TonePlayer built on AVAudioEngine with an AVAudioUnitSampler, a pure PlaybackSchedule, a BackupService with DTOs, SwiftUI views and unit tests. It also gives a verification plan that combines xcodebuild, tests, coverage and manual checks on a real device.

**How the existing system works, per this document**

There is no existing software. The document describes the current manual practice instead. Starting notes come from a tuning fork, a piano or a generic tuner app. The pitches for each song are memorised or written on paper and then looked up one by one, which is slow between songs on stage and error-prone for notes with accidentals. Generic tuner apps have no idea of a running order. The author's development machine runs Windows 11, so building the app needs a Mac that has not been chosen yet (Open Question).

--------------------------------------------------------------------------------

## Findings

1. **Severity:** Major
   **Affected Scope:** G2 (lines 51–53) vs. "Eingabe"/PitchPicker (lines 253–256, 748–751)
   **Description:** G2 says a pitch is picked from three parts: note name, accidental and octave. The architecture and file 16 describe only two wheels: a 12-value note-name wheel and an octave wheel. That wheel list is labelled "Kreuz-Schreibweise" (sharp spelling), but it contains "B", which is B♭, a flat. So the document does not say whether a separate accidental control exists. It also does not say how the "Kreuz-Schreibweise" label fits with B being a flat. A reader cannot tell what the input looks like.

2. **Severity:** Major
   **Affected Scope:** G5 (lines 67–68), "Bildschirm" (lines 311–314), ChorAssistentApp (lines 578–579), ConcertPlayerView (lines 801–802)
   **Description:** `isIdleTimerDisabled` is set to true only in `onAppear`. When the app goes to the background it is set back to false. Nothing says it is set to true again when the app returns to the foreground while concert mode is still open, and `onAppear` does not normally fire again in that case. G5 promises that the screen does not lock while concert mode is open. The document does not explain how that promise survives a background/foreground cycle, for example after a phone call or a short app switch on stage.

3. **Severity:** Major
   **Affected Scope:** PlayButton (lines 756–761), `isPlaying` (lines 287–288), SongListView (lines 724–728)
   **Description:** `isPlaying` is one flag on the shared TonePlayer, and the song list shows a PlayButton on every row. The document does not say whether every row button switches to the restart icon while any song is playing. It also does not say what tapping a different row's button means at that moment: restart, or play the other song. "gestoppt wird über den Wechsel der Ansicht" is vague. Only ConcertPlayerView is described as calling `stop()`. Leaving SongListView or SongEditView is never described as stopping playback, so it is unclear how a reader stops sound outside concert mode.

4. **Severity:** Major
   **Affected Scope:** ConcertPlayerView "Lied gelöscht" (lines 793–794, 803–804)
   **Description:** The view works from a snapshot of `orderedEntries` and shows "Lied gelöscht" if a song was deleted. Concert mode is a `fullScreenCover`, so the library cannot be reached while it is open. In addition, `.cascade` removes the entries themselves, not just their `song` link. The document does not explain how or when this situation can happen, or what the snapshot actually holds once its entry objects are deleted. The reader cannot reconstruct the intended scenario.

5. **Severity:** Nit
   **Affected Scope:** `renumber` signature (lines 232, 600, 623)
   **Description:** The function is named in three different ways: `Concert.renumber(orderedEntries:)`, `renumber(_ ordered:)` and `renumber(orderedEntries)`. For something the document calls the only writer of positions, the name and signature should be consistent.

6. **Severity:** Nit
   **Affected Scope:** `append(song:, in:)` (lines 602–603)
   **Description:** `append` creates an entry and then calls `renumber`, presumably with `orderedEntries`, which is sorted by `position`. The document does not say which `position` the new entry gets before `renumber` runs. If it defaulted to 0, it could sort to the front. The intended initial value should be stated.

7. **Severity:** Nit
   **Affected Scope:** "Positionen pflegen" (line 230)
   **Description:** "Das ist die bekannte Fehlerquelle dieser Wahl" refers to a choice (ConcertEntry with a `position` field instead of an ID array) that is only explained later, in Alternative R1 (lines 501–511). A reader at line 230 does not know which choice is meant.

8. **Severity:** Nit
   **Affected Scope:** Import validation (lines 339–341 vs. 705–706)
   **Description:** The feature section lists three checks. File 12 adds a fourth: "keine doppelten IDs". The feature section should list all four checks or point to the full list.

9. **Severity:** Nit
   **Affected Scope:** Export `settings` block (lines 327, 349–351, 700)
   **Description:** The format marks `settings` as optional, but the export always writes it. The document does not say what happens on import when the block is missing: whether the current settings are kept or reset to the defaults.

10. **Severity:** Nit
    **Affected Scope:** Data model field `note` (lines 218, 328, 585)
    **Description:** In a music app, `note: String` reads like a musical note. It is actually the free-text comment (Notiz), while the pitches are stored in `pitches`. The table should say that `note` is the Notiz.

11. **Severity:** Nit
    **Affected Scope:** "Probe" button (lines 282, 811–812)
    **Description:** "Probe" also means "rehearsal", the sense CUJ 2 uses (line 132). The button that plays C4–E4–G4 with the current settings could be misread as a rehearsal feature. Calling it a test or preview would avoid that.

12. **Severity:** Nit
    **Affected Scope:** `preview(midi:)` (line 666), PitchPicker (line 749)
    **Description:** The document does not say whether a preview stops a sequence that is already playing, or whether it can sound on top of it. It also does not say whether the preview changes `isPlaying`.

13. **Severity:** Nit
    **Affected Scope:** `loadSoundBankInstrument(... bankMSB:0x79 ...)` (line 266)
    **Description:** The magic value 0x79 (the General MIDI melodic bank) is not explained. A reader without SoundFont/GM background cannot tell why it is used.

14. **Severity:** Nit
    **Affected Scope:** Risk table, "SwiftData-Fehler in iOS 17/18 bei Beziehungen" (line 366)
    **Description:** The risk is vague. It names no specific known bug, and has no link. That makes it hard to judge whether the listed countermeasures address it.

15. **Severity:** Nit
    **Affected Scope:** Alternatives Considered preamble (lines 372–376) vs. "Rejected by author: …" entries
    **Description:** The preamble says the author gave no reasons of their own. Each entry then says "Rejected by author:" followed by a statement that reads like the author's reasoning. The wording should make clear that these are the downsides raised in the session, not the author's stated reasons.
