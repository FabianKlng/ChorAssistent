import Foundation
import SwiftData
import Testing

@testable import ChorAssistent

@MainActor
struct BackupServiceTests {
    /// Bibliothek mit doppeltem Eintrag und Notizen.
    private func makeLibrary(_ store: TestStore) throws {
        let a = store.addSong("Abendlied", [62, 66, 69], memo: "Tenor beginnt")
        let b = store.addSong("Bona nox", [60, 64])
        let concert = store.addConcert("Advent")
        for song in [a, b, a] {
            concert.append(song: song, in: store.context)
        }
        try store.context.save()
    }

    /// Über JSON normalisiert (Datumsangaben auf ganze Sekunden).
    private func normalized(_ file: BackupFile) throws -> BackupFile {
        try BackupFile.makeDecoder().decode(BackupFile.self, from: BackupService.encode(file))
    }

    private func counts(_ store: TestStore) throws -> (songs: Int, concerts: Int) {
        (
            try store.context.fetchCount(FetchDescriptor<Song>()),
            try store.context.fetchCount(FetchDescriptor<Concert>())
        )
    }

    @Test func roundTrip() throws {
        let source = try TestStore()
        try makeLibrary(source)
        let defaults = makeTestDefaults()
        let exported = try normalized(BackupService.makeFile(context: source.context, defaults: defaults))

        let target = try TestStore()
        target.addSong("Wird ersetzt")
        try target.context.save()
        let decoded = try BackupService.decodeAndValidate(BackupService.encode(exported))
        try BackupService.replaceLibrary(with: decoded, context: target.context, defaults: defaults)

        let reimported = try normalized(BackupService.makeFile(context: target.context, defaults: defaults))
        #expect(reimported.songs == exported.songs)
        #expect(reimported.concerts == exported.concerts)
        #expect(exported.concerts.first?.songIDs.count == 3)
    }

    @Test func unknownVersion() throws {
        let data = Data(#"{"formatVersion": 9}"#.utf8)
        #expect(throws: BackupError.unknownVersion(9)) {
            try BackupService.decodeAndValidate(data)
        }
    }

    @Test func unreadable() {
        #expect(throws: BackupError.unreadable) {
            try BackupService.decodeAndValidate(Data("kein json".utf8))
        }
    }

    @Test(arguments: [[20], Array(repeating: 60, count: 9)])
    func invalidPitches(pitches: [Int]) throws {
        let file = makeFile(songs: [song("X", pitches)])
        #expect(throws: BackupError.self) { try BackupService.validate(file) }
    }

    @Test func emptyTitle() {
        let file = makeFile(songs: [song("  ", [60])])
        #expect(throws: BackupError.invalidSong(title: "  ", reason: .emptyTitle)) {
            try BackupService.validate(file)
        }
    }

    @Test func duplicateID() {
        let one = song("A", [60])
        var two = song("B", [62])
        two.id = one.id
        #expect(throws: BackupError.duplicateID) { try BackupService.validate(makeFile(songs: [one, two])) }
    }

    @Test func unknownSongID() {
        let concert = ConcertDTO(id: UUID(), name: "K", createdAt: .now, songIDs: [UUID()])
        #expect(throws: BackupError.unknownSongID) {
            try BackupService.validate(makeFile(songs: [song("A", [60])], concerts: [concert]))
        }
    }

    @Test func invalidFileLeavesLibraryUnchanged() throws {
        let store = try TestStore()
        try makeLibrary(store)
        let before = try counts(store)
        #expect(throws: BackupError.self) {
            let file = try BackupService.decodeAndValidate(Data(#"{"formatVersion": 9}"#.utf8))
            try BackupService.replaceLibrary(with: file, context: store.context)
        }
        let after = try counts(store)
        #expect(after.songs == before.songs)
        #expect(after.concerts == before.concerts)
    }

    @Test func tooLarge() throws {
        let url = temporaryFileURL()
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try Data(count: 1_001).write(to: url)
        #expect(throws: BackupError.tooLarge) { try BackupService.load(from: url, maxSize: 1_000) }
    }

    @Test func settingsAreClamped() throws {
        let store = try TestStore()
        let defaults = makeTestDefaults()
        var file = makeFile(songs: [song("A", [60])])
        file.settings = SettingsDTO(toneDuration: 10, gap: -1)
        try BackupService.replaceLibrary(with: file, context: store.context, defaults: defaults)
        #expect(PlaybackSettings.toneDuration(defaults) == PlaybackSettings.toneDurationRange.upperBound)
        #expect(PlaybackSettings.gap(defaults) == PlaybackSettings.gapRange.lowerBound)
    }

    @Test func missingSettingsKeepCurrentValues() throws {
        let store = try TestStore()
        let defaults = makeTestDefaults()
        defaults.set(2.0, forKey: PlaybackSettings.toneDurationKey)
        defaults.set(0.5, forKey: PlaybackSettings.gapKey)
        try BackupService.replaceLibrary(
            with: makeFile(songs: [song("A", [60])]),
            context: store.context,
            defaults: defaults
        )
        #expect(PlaybackSettings.toneDuration(defaults) == 2.0)
        #expect(PlaybackSettings.gap(defaults) == 0.5)
    }

    @Test func safetyBackupAndUndo() throws {
        let store = try TestStore()
        try makeLibrary(store)
        let defaults = makeTestDefaults()
        let safetyURL = temporaryFileURL("Sicherung-vor-Import.json")
        try FileManager.default.createDirectory(
            at: safetyURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        let first = makeFile(songs: [song("Erster Import", [60])])
        try BackupService.importReplacing(first, context: store.context, safetyURL: safetyURL, defaults: defaults)
        #expect(BackupService.hasSafetyBackup(at: safetyURL))
        #expect(try counts(store).songs == 1)

        // Ein zweiter Import überschreibt die Sicherung: Sie enthält jetzt den Stand nach dem ersten Import.
        let second = makeFile(songs: [song("Zweiter Import", [62]), song("Noch eins", [64])])
        try BackupService.importReplacing(second, context: store.context, safetyURL: safetyURL, defaults: defaults)
        #expect(try counts(store).songs == 2)

        // Rückgängig stellt den Stand vor dem letzten Import her und löscht die Sicherung.
        try BackupService.undoLastImport(context: store.context, safetyURL: safetyURL, defaults: defaults)
        let restored = try normalized(BackupService.makeFile(context: store.context, defaults: defaults))
        #expect(restored.songs.map(\.title) == ["Erster Import"])
        #expect(!BackupService.hasSafetyBackup(at: safetyURL))
    }

    // MARK: Version 2: Noten und Konzertdatum

    @Test func scorePagesAndDateSurviveRoundTrip() throws {
        let source = try TestStore()
        let song = source.addSong("Mit Noten", [60, 64])
        song.addScorePage(Data([0xFF, 0xD8, 0x01]), in: source.context)
        song.addScorePage(Data([0xFF, 0xD8, 0x02]), in: source.context)
        let concert = source.addConcert("Advent")
        concert.date = Self.fixedDate
        concert.append(song: song, in: source.context)
        try source.context.save()

        let exported = try normalized(BackupService.makeFile(context: source.context))
        #expect(exported.formatVersion == 2)
        #expect(exported.songs.first?.scorePages?.map(\.pageNumber) == [1, 2])

        let target = try TestStore()
        try BackupService.replaceLibrary(with: exported, context: target.context, defaults: makeTestDefaults())
        let reimported = try normalized(BackupService.makeFile(context: target.context))
        #expect(reimported.songs == exported.songs)
        #expect(reimported.concerts.first?.date == Self.fixedDate)
    }

    @Test func versionOneFileIsStillReadable() throws {
        let json = """
            {
              "formatVersion": 1,
              "exportedAt": "2026-11-15T12:00:00Z",
              "songs": [{"id": "6F1C2A47-1B6F-4E8B-9C1E-2B3A4C5D6E7F", "title": "Alt", "memo": "",
                         "pitches": [60], "createdAt": "2026-11-15T12:00:00Z"}],
              "concerts": [{"id": "0A1B2C3D-4E5F-4061-8728-394A5B6C7D8E", "name": "K",
                            "createdAt": "2026-11-15T12:00:00Z",
                            "songIDs": ["6F1C2A47-1B6F-4E8B-9C1E-2B3A4C5D6E7F"]}]
            }
            """
        let file = try BackupService.decodeAndValidate(Data(json.utf8))
        #expect(file.songs.first?.scorePages == nil)
        #expect(file.concerts.first?.date == nil)

        let store = try TestStore()
        try BackupService.replaceLibrary(with: file, context: store.context, defaults: makeTestDefaults())
        #expect(try counts(store).songs == 1)
    }

    @Test func deletingSongDeletesItsScorePages() throws {
        let store = try TestStore()
        let song = store.addSong("A")
        song.addScorePage(Data([1]), in: store.context)
        try store.context.save()
        #expect(try store.context.fetchCount(FetchDescriptor<ScorePage>()) == 1)

        try LibraryActions.delete(song: song, in: store.context)
        #expect(try store.context.fetchCount(FetchDescriptor<ScorePage>()) == 0)
    }

    // MARK: Hilfen

    private static let fixedDate = Date(timeIntervalSince1970: 1_700_000_000)

    private func song(_ title: String, _ pitches: [Int]) -> SongDTO {
        SongDTO(id: UUID(), title: title, memo: "", pitches: pitches, createdAt: Self.fixedDate)
    }

    private func makeFile(songs: [SongDTO], concerts: [ConcertDTO] = []) -> BackupFile {
        BackupFile(
            formatVersion: BackupFile.currentVersion,
            exportedAt: Self.fixedDate,
            settings: nil,
            songs: songs,
            concerts: concerts
        )
    }

    // MARK: Export, Laden, Fehlermeldungen

    @Test func writeExportCreatesNamedJSONFile() throws {
        let store = try TestStore()
        try makeLibrary(store)
        let url = try BackupService.writeExport(context: store.context)
        defer { try? FileManager.default.removeItem(at: url) }

        #expect(url.lastPathComponent.hasPrefix("ChorAssistent-Sicherung-"))
        #expect(url.pathExtension == "json")
        let file = try BackupService.decodeAndValidate(Data(contentsOf: url))
        #expect(file.songs.map(\.title) == ["Abendlied", "Bona nox"])
    }

    @Test func loadValidFile() throws {
        let url = temporaryFileURL()
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        let file = makeFile(songs: [song("A", [60])])
        try BackupService.encode(file).write(to: url)

        #expect(try BackupService.load(from: url).songs.map(\.title) == ["A"])
    }

    @Test func loadMissingFileIsUnreadable() {
        #expect(throws: BackupError.unreadable) { try BackupService.load(from: temporaryFileURL()) }
    }

    @Test func undoWithoutSafetyBackupIsUnreadable() throws {
        let store = try TestStore()
        #expect(throws: BackupError.unreadable) {
            try BackupService.undoLastImport(context: store.context, safetyURL: temporaryFileURL())
        }
    }

    @Test func everyErrorHasAGermanMessage() {
        let errors: [BackupError] = [
            .tooLarge, .unreadable, .unknownVersion(3), .invalidSong(title: "X", reason: .noPitches),
            .duplicateID, .unknownSongID, .saveFailed,
        ]
        for error in errors {
            #expect(!(error.errorDescription ?? "").isEmpty)
        }
        #expect(BackupError.unknownVersion(3).errorDescription == "Unbekannte Dateiversion 3")
    }
}
