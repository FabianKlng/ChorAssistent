import Foundation
import SwiftData

/// Änderungen, die mehrere Modelle betreffen.
enum LibraryActions {
    /// Löscht ein Lied. Reihenfolge ist wichtig: SwiftData entfernt die per
    /// `.cascade` gelöschten Einträge erst beim Speichern aus `Concert.entries`.
    /// Deshalb werden die verbleibenden Einträge vorher selbst bestimmt und
    /// durchnummeriert.
    static func delete(song: Song, in context: ModelContext) throws {
        for concert in concerts(containing: song) {
            let remaining = concert.orderedEntries.filter { $0.song?.persistentModelID != song.persistentModelID }
            concert.renumber(orderedEntries: remaining)
        }
        context.delete(song)
        try context.save()
    }

    /// Anzahl verschiedener Konzerte, in denen das Lied vorkommt.
    static func concertCount(for song: Song) -> Int {
        concerts(containing: song).count
    }

    private static func concerts(containing song: Song) -> [Concert] {
        var seen: [PersistentIdentifier: Concert] = [:]
        for entry in song.entries where !entry.isDeleted {
            if let concert = entry.concert {
                seen[concert.persistentModelID] = concert
            }
        }
        return Array(seen.values)
    }
}
