import Foundation
import Testing

@testable import ChorAssistent

@MainActor
struct ConcertOrderingTests {
    private func titles(_ concert: Concert) -> [String] {
        concert.orderedEntries.compactMap { $0.song?.title }
    }

    private func positions(_ concert: Concert) -> [Int] {
        concert.orderedEntries.map(\.position)
    }

    @Test func appendMoveRemoveKeepPositionsContiguous() throws {
        let store = try TestStore()
        let concert = store.addConcert("Advent")
        for title in ["A", "B", "C", "D"] {
            concert.append(song: store.addSong(title), in: store.context)
            #expect(positions(concert) == Array(0..<concert.orderedEntries.count))
        }
        #expect(titles(concert) == ["A", "B", "C", "D"])

        concert.move(fromOffsets: [0], toOffset: 3)
        #expect(titles(concert) == ["B", "C", "A", "D"])
        #expect(positions(concert) == [0, 1, 2, 3])

        concert.remove(atOffsets: [1], in: store.context)
        try store.context.save()
        #expect(titles(concert) == ["B", "A", "D"])
        #expect(positions(concert) == [0, 1, 2])
    }

    @Test func movedMatchesSwiftUISemantics() {
        #expect(Concert.moved(["A", "B", "C", "D"], fromOffsets: [0], toOffset: 3) == ["B", "C", "A", "D"])
        #expect(Concert.moved(["A", "B", "C", "D"], fromOffsets: [3], toOffset: 0) == ["D", "A", "B", "C"])
        #expect(Concert.moved(["A", "B", "C", "D"], fromOffsets: [1], toOffset: 4) == ["A", "C", "D", "B"])
    }

    @Test func deletingSongRemovesAllItsEntries() throws {
        let store = try TestStore()
        let concert = store.addConcert("Frühjahr")
        let a = store.addSong("A")
        let b = store.addSong("B")
        let c = store.addSong("C")
        for song in [a, b, c, b] {
            concert.append(song: song, in: store.context)
        }
        try store.context.save()
        #expect(LibraryActions.concertCount(for: b) == 1)

        try LibraryActions.delete(song: b, in: store.context)

        #expect(titles(concert) == ["A", "C"])
        #expect(positions(concert) == [0, 1])
    }

    @Test func equalPositionsSortStablyById() throws {
        let store = try TestStore()
        let concert = store.addConcert("Test")
        for title in ["A", "B", "C"] {
            concert.append(song: store.addSong(title), in: store.context)
        }
        for entry in concert.entries {
            entry.position = 0
        }
        let first = concert.orderedEntries.map(\.id)
        let second = concert.orderedEntries.map(\.id)
        #expect(first == second)
        #expect(first == first.sorted { $0.uuidString < $1.uuidString })
    }
}
