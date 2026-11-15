import Foundation
import SwiftData

/// Gründe, aus denen ein Lied nicht gespeichert werden darf.
enum SongValidationError: Error, Equatable {
    case emptyTitle
    case noPitches
    case tooManyPitches
    case pitchOutOfRange(Int)

    var message: String {
        switch self {
        case .emptyTitle:
            return "Titel fehlt"
        case .noPitches:
            return "Mindestens ein Ton nötig"
        case .tooManyPitches:
            return "Höchstens \(Song.maxPitches) Töne"
        case .pitchOutOfRange(let midi):
            return "Ton \(midi) liegt außerhalb von C2–C6"
        }
    }
}

@Model
final class Song {
    // Bewusst kein @Attribute(.unique): Der Import löscht und legt Lieder mit
    // derselben ID neu an. Die Eindeutigkeit prüft BackupService.validate.
    var id: UUID
    var title: String
    /// Die Notiz zum Lied (z. B. „Tenor beginnt"), leer erlaubt.
    var memo: String
    /// MIDI-Nummern in Abspielreihenfolge.
    var pitches: [Int]
    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \ConcertEntry.song)
    var entries: [ConcertEntry] = []

    @Relationship(deleteRule: .cascade, inverse: \ScorePage.song)
    var scorePages: [ScorePage] = []

    init(id: UUID = UUID(), title: String, memo: String = "", pitches: [Int], createdAt: Date = .now) {
        self.id = id
        self.title = title
        self.memo = memo
        self.pitches = pitches
        self.createdAt = createdAt
    }
}

extension Song {
    static let pitchRange = 36...84
    static let maxPitches = 8

    /// Gemeinsame Prüfregel für das Formular und den Import.
    static func validate(title: String, pitches: [Int]) -> SongValidationError? {
        if title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return .emptyTitle
        }
        if pitches.isEmpty {
            return .noPitches
        }
        if pitches.count > maxPitches {
            return .tooManyPitches
        }
        if let outside = pitches.first(where: { !pitchRange.contains($0) }) {
            return .pitchOutOfRange(outside)
        }
        return nil
    }
}
