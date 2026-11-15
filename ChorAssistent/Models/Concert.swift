import Foundation
import SwiftData

@Model
final class Concert {
    var id: UUID
    var name: String
    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \ConcertEntry.concert)
    var entries: [ConcertEntry] = []

    init(id: UUID = UUID(), name: String, createdAt: Date = .now) {
        self.id = id
        self.name = name
        self.createdAt = createdAt
    }
}

extension Concert {
    /// Die gültige Liedfolge: ohne gelöschte Einträge und ohne Einträge ohne Lied,
    /// sortiert nach Position und bei Gleichstand nach ID (stabil).
    var orderedEntries: [ConcertEntry] {
        entries
            .filter { !$0.isDeleted && $0.song != nil }
            .sorted { ($0.position, $0.id.uuidString) < ($1.position, $1.id.uuidString) }
    }

    /// Die einzige Stelle, die `position` schreibt.
    func renumber(orderedEntries ordered: [ConcertEntry]) {
        for (index, entry) in ordered.enumerated() where entry.position != index {
            entry.position = index
        }
    }

    func append(song: Song, in context: ModelContext) {
        let current = orderedEntries
        let entry = ConcertEntry(position: current.count)
        context.insert(entry)
        entry.song = song
        entry.concert = self
        renumber(orderedEntries: current + [entry])
    }

    func remove(atOffsets offsets: IndexSet, in context: ModelContext) {
        let current = orderedEntries
        let remaining = current.enumerated()
            .filter { !offsets.contains($0.offset) }
            .map(\.element)
        for offset in offsets where current.indices.contains(offset) {
            context.delete(current[offset])
        }
        renumber(orderedEntries: remaining)
    }

    func move(fromOffsets source: IndexSet, toOffset destination: Int) {
        renumber(orderedEntries: Self.moved(orderedEntries, fromOffsets: source, toOffset: destination))
    }

    /// Bildet `MutableCollection.move(fromOffsets:toOffset:)` aus SwiftUI nach:
    /// Die Elemente bei `source` werden vor dem ursprünglichen Index `destination` eingefügt.
    static func moved<Element>(_ array: [Element], fromOffsets source: IndexSet, toOffset destination: Int)
        -> [Element]
    {
        let moving = source.filter { array.indices.contains($0) }.map { array[$0] }
        var result: [Element] = []
        result.reserveCapacity(array.count)
        for (index, element) in array.enumerated() {
            if index == destination {
                result.append(contentsOf: moving)
            }
            if !source.contains(index) {
                result.append(element)
            }
        }
        if destination >= array.count {
            result.append(contentsOf: moving)
        }
        return result
    }
}
