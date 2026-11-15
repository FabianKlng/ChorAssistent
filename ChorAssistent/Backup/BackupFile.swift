import Foundation

/// Das Exportformat. Konzerte stehen darin als geordnete Liste von Lied-IDs.
struct BackupFile: Codable, Equatable {
    static let currentVersion = 1

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
}

struct ConcertDTO: Codable, Equatable {
    var id: UUID
    var name: String
    var createdAt: Date
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
