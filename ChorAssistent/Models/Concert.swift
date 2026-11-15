import Foundation
import SwiftData

@Model
final class Concert {
    var id: UUID
    var name: String
    var createdAt: Date
    /// Optionales Datum des Auftritts; bestimmt das „nächste Konzert".
    var date: Date?

    @Relationship(deleteRule: .cascade, inverse: \ConcertEntry.concert)
    var entries: [ConcertEntry] = []

    init(id: UUID = UUID(), name: String, createdAt: Date = .now, date: Date? = nil) {
        self.id = id
        self.name = name
        self.createdAt = createdAt
        self.date = date
    }
}

extension Concert {
    /// Das Konzert für die Startseite: das nächste mit Datum ab heute,
    /// sonst das zuletzt angelegte ohne Datum, sonst keins.
    static func next(from concerts: [Concert], now: Date, calendar: Calendar = .current) -> Concert? {
        let today = calendar.startOfDay(for: now)
        let upcoming = concerts.compactMap { concert -> (Concert, Date)? in
            guard let date = concert.date, date >= today else { return nil }
            return (concert, date)
        }
        if let first = upcoming.min(by: { $0.1 < $1.1 }) {
            return first.0
        }
        return concerts.filter { $0.date == nil }.max { $0.createdAt < $1.createdAt }
    }

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
