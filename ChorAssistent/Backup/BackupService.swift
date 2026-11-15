import Foundation
import SwiftData

enum BackupError: LocalizedError, Equatable {
    case tooLarge
    case unreadable
    case unknownVersion(Int)
    case invalidSong(title: String, reason: SongValidationError)
    case duplicateID
    case unknownSongID
    case saveFailed

    var errorDescription: String? {
        switch self {
        case .tooLarge:
            return "Datei größer als 200 MB"
        case .unreadable:
            return "Datei nicht lesbar"
        case .unknownVersion(let version):
            return "Unbekannte Dateiversion \(version)"
        case .invalidSong(let title, let reason):
            return "Lied „\(title)“ ungültig: \(reason.message)"
        case .duplicateID:
            return "Doppelte ID in der Datei"
        case .unknownSongID:
            return "Konzert verweist auf ein unbekanntes Lied"
        case .saveFailed:
            return "Speichern fehlgeschlagen, Bibliothek unverändert"
        }
    }
}

@MainActor
enum BackupService {
    /// Mit Notenscans kann eine Sicherung groß werden.
    static let maxFileSize = 200_000_000

    static var safetyBackupURL: URL {
        URL.documentsDirectory.appending(path: "Sicherung-vor-Import.json")
    }

    // MARK: Export

    static func makeFile(context: ModelContext, defaults: UserDefaults = .standard, now: Date = .now) throws
        -> BackupFile
    {
        // Im Speicher sortiert: SortDescriptor mit KeyPath ist unter strenger Nebenläufigkeit nicht Sendable.
        let songs = try context.fetch(FetchDescriptor<Song>()).sorted { $0.title < $1.title }
        let concerts = try context.fetch(FetchDescriptor<Concert>()).sorted { $0.createdAt < $1.createdAt }
        return BackupFile(
            formatVersion: BackupFile.currentVersion,
            exportedAt: now,
            settings: PlaybackSettings.current(defaults),
            songs: songs.map { song in
                SongDTO(
                    id: song.id,
                    title: song.title,
                    memo: song.memo,
                    pitches: song.pitches,
                    createdAt: song.createdAt,
                    scorePages: song.sortedScorePages.map {
                        ScorePageDTO(id: $0.id, pageNumber: $0.pageNumber, imageData: $0.imageData)
                    }
                )
            },
            concerts: concerts.map { concert in
                ConcertDTO(
                    id: concert.id,
                    name: concert.name,
                    createdAt: concert.createdAt,
                    date: concert.date,
                    songIDs: concert.orderedEntries.compactMap { $0.song?.id }
                )
            }
        )
    }

    static func encode(_ file: BackupFile) throws -> Data {
        try BackupFile.makeEncoder().encode(file)
    }

    /// Schreibt die Exportdatei in den temporären Ordner und gibt ihre URL zurück.
    static func writeExport(context: ModelContext) throws -> URL {
        let file = try makeFile(context: context)
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        let url = URL.temporaryDirectory.appending(
            path: "ChorAssistent-Sicherung-\(formatter.string(from: file.exportedAt)).json")
        try encode(file).write(to: url, options: .atomic)
        return url
    }

    // MARK: Lesen und Prüfen

    static func load(from url: URL, maxSize: Int = maxFileSize) throws -> BackupFile {
        let scoped = url.startAccessingSecurityScopedResource()
        defer {
            if scoped { url.stopAccessingSecurityScopedResource() }
        }
        // Größe vor dem Lesen prüfen.
        if let size = try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize, size > maxSize {
            throw BackupError.tooLarge
        }
        let data: Data
        do {
            data = try Data(contentsOf: url)
        } catch {
            throw BackupError.unreadable
        }
        return try decodeAndValidate(data, maxSize: maxSize)
    }

    static func decodeAndValidate(_ data: Data, maxSize: Int = maxFileSize) throws -> BackupFile {
        guard data.count <= maxSize else { throw BackupError.tooLarge }
        let decoder = BackupFile.makeDecoder()
        guard let probe = try? decoder.decode(BackupVersionProbe.self, from: data) else {
            throw BackupError.unreadable
        }
        guard BackupFile.supportedVersions.contains(probe.formatVersion) else {
            throw BackupError.unknownVersion(probe.formatVersion)
        }
        guard let file = try? decoder.decode(BackupFile.self, from: data) else {
            throw BackupError.unreadable
        }
        try validate(file)
        return file
    }

    static func validate(_ file: BackupFile) throws {
        guard BackupFile.supportedVersions.contains(file.formatVersion) else {
            throw BackupError.unknownVersion(file.formatVersion)
        }
        for song in file.songs {
            if let reason = Song.validate(title: song.title, pitches: song.pitches) {
                throw BackupError.invalidSong(title: song.title, reason: reason)
            }
        }
        let songIDs = file.songs.map(\.id)
        let concertIDs = file.concerts.map(\.id)
        guard Set(songIDs).count == songIDs.count, Set(concertIDs).count == concertIDs.count else {
            throw BackupError.duplicateID
        }
        let known = Set(songIDs)
        for concert in file.concerts where !concert.songIDs.allSatisfy(known.contains) {
            throw BackupError.unknownSongID
        }
    }

    // MARK: Ersetzen, Import, Rückgängig

    /// Ersetzt die gesamte Bibliothek. Läuft im Haupt-Kontext mit ausgeschaltetem
    /// Autosave; Objekte werden einzeln gelöscht (kein Batch-Delete), damit ein
    /// Rollback alles zurücknehmen kann. Einstellungen nur bei Erfolg.
    static func replaceLibrary(with file: BackupFile, context: ModelContext, defaults: UserDefaults = .standard)
        throws
    {
        let previousAutosave = context.autosaveEnabled
        context.autosaveEnabled = false
        defer { context.autosaveEnabled = previousAutosave }

        do {
            for concert in try context.fetch(FetchDescriptor<Concert>()) {
                context.delete(concert)
            }
            for song in try context.fetch(FetchDescriptor<Song>()) {
                context.delete(song)
            }

            var songsByID: [UUID: Song] = [:]
            for dto in file.songs {
                let song = Song(
                    id: dto.id,
                    title: dto.title,
                    memo: dto.memo,
                    pitches: dto.pitches,
                    createdAt: dto.createdAt
                )
                context.insert(song)
                songsByID[dto.id] = song
                for pageDTO in (dto.scorePages ?? []).sorted(by: { $0.pageNumber < $1.pageNumber }) {
                    let page = ScorePage(id: pageDTO.id, pageNumber: pageDTO.pageNumber, imageData: pageDTO.imageData)
                    context.insert(page)
                    page.song = song
                }
            }
            for dto in file.concerts {
                let concert = Concert(id: dto.id, name: dto.name, createdAt: dto.createdAt, date: dto.date)
                context.insert(concert)
                var created: [ConcertEntry] = []
                for songID in dto.songIDs {
                    guard let song = songsByID[songID] else { continue }
                    let entry = ConcertEntry(position: created.count)
                    context.insert(entry)
                    entry.song = song
                    entry.concert = concert
                    created.append(entry)
                }
                concert.renumber(orderedEntries: created)
            }
            try context.save()
        } catch {
            context.rollback()
            throw BackupError.saveFailed
        }

        PlaybackSettings.apply(file.settings, to: defaults)
    }

    /// Schreibt eine Sicherung der aktuellen Bibliothek. Überschreibt die vorige.
    static func writeSafetyBackup(context: ModelContext, to url: URL? = nil, defaults: UserDefaults = .standard)
        throws
    {
        let file = try makeFile(context: context, defaults: defaults)
        try encode(file).write(to: url ?? safetyBackupURL, options: .atomic)
    }

    static func hasSafetyBackup(at url: URL? = nil) -> Bool {
        FileManager.default.fileExists(atPath: (url ?? safetyBackupURL).path(percentEncoded: false))
    }

    /// Sicherung schreiben, dann ersetzen.
    static func importReplacing(
        _ file: BackupFile, context: ModelContext, safetyURL: URL? = nil, defaults: UserDefaults = .standard
    ) throws {
        try writeSafetyBackup(context: context, to: safetyURL, defaults: defaults)
        try replaceLibrary(with: file, context: context, defaults: defaults)
    }

    /// Spielt die letzte Sicherung ein, ohne Rückfrage und ohne neue Sicherung.
    /// Bei Erfolg wird die Sicherungsdatei gelöscht.
    static func undoLastImport(context: ModelContext, safetyURL: URL? = nil, defaults: UserDefaults = .standard)
        throws
    {
        let url = safetyURL ?? safetyBackupURL
        let data: Data
        do {
            data = try Data(contentsOf: url)
        } catch {
            throw BackupError.unreadable
        }
        let file = try decodeAndValidate(data)
        try replaceLibrary(with: file, context: context, defaults: defaults)
        try? FileManager.default.removeItem(at: url)
    }
}
