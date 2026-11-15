import Foundation

/// Das Exportformat. Konzerte stehen darin als geordnete Liste von Lied-IDs.
/// Version 2 ergänzt Notenseiten (JPEG, Base64) und das Konzertdatum; Version 1 bleibt lesbar.
struct BackupFile: Codable, Equatable {
    static let currentVersion = 2
    static let supportedVersions: Set<Int> = [1, 2]

    var formatVersion: Int
    var exportedAt: Date
    var settings: SettingsDTO?
    var songs: [SongDTO]
    var concerts: [ConcertDTO]

    /// `.iso8601` verliert Sekundenbruchteile; Vergleiche erfolgen auf ganze Sekunden.
    static func makeEncoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return encoder
    }

    static func makeDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}

struct SongDTO: Codable, Equatable {
    var id: UUID
    var title: String
    var memo: String
    var pitches: [Int]
    var createdAt: Date
    /// Ab Version 2; fehlt in Version 1.
    var scorePages: [ScorePageDTO]?
}

struct ScorePageDTO: Codable, Equatable {
    var id: UUID
    var pageNumber: Int
    /// JPEG, im JSON als Base64.
    var imageData: Data
}

struct ConcertDTO: Codable, Equatable {
    var id: UUID
    var name: String
    var createdAt: Date
    /// Ab Version 2; fehlt in Version 1.
    var date: Date?
    var songIDs: [UUID]
}

struct SettingsDTO: Codable, Equatable {
    var toneDuration: Double
    var gap: Double
}

/// Liest nur die Version, damit eine unbekannte Version nicht als „unlesbar" gilt.
struct BackupVersionProbe: Decodable {
    var formatVersion: Int
}
