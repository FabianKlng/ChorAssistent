import Foundation
import SwiftData

/// Ein Platz in einem Konzert. Ein Lied kann mehrere Plätze haben.
@Model
final class ConcertEntry {
    var id: UUID
    /// Wird nur von `Concert.renumber(orderedEntries:)` geschrieben.
    var position: Int
    var song: Song?
    var concert: Concert?

    /// Beziehungen werden erst nach `context.insert` gesetzt.
    init(position: Int) {
        self.id = UUID()
        self.position = position
    }
}
