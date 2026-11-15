import Foundation
import Testing
import UIKit

@testable import ChorAssistent

@MainActor
struct ScorePageTests {
    @Test func pagesAreAppendedInOrder() throws {
        let store = try TestStore()
        let song = store.addSong("A")
        song.addScorePage(Data([1]), in: store.context)
        song.addScorePage(Data([2]), in: store.context)
        song.addScorePage(Data([3]), in: store.context)
        #expect(song.sortedScorePages.map(\.pageNumber) == [1, 2, 3])
        #expect(song.sortedScorePages.map(\.imageData) == [Data([1]), Data([2]), Data([3])])
    }

    @Test func pageNumberContinuesAfterDeletion() throws {
        let store = try TestStore()
        let song = store.addSong("A")
        song.addScorePage(Data([1]), in: store.context)
        let second = song.addScorePage(Data([2]), in: store.context)
        try store.context.save()
        store.context.delete(second)
        try store.context.save()
        let third = song.addScorePage(Data([3]), in: store.context)
        #expect(third.pageNumber == 2)
    }
}

struct ImageCompressorTests {
    @Test func largeImagesAreScaledToMaxDimension() {
        let size = ImageCompressor.targetSize(for: CGSize(width: 3000, height: 4000))
        #expect(size == CGSize(width: 1500, height: 2000))
    }

    @Test func smallImagesStayUnchanged() {
        let size = ImageCompressor.targetSize(for: CGSize(width: 800, height: 600))
        #expect(size == CGSize(width: 800, height: 600))
    }

    @Test func jpegDataIsDecodableAndScaled() throws {
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1
        let image = UIGraphicsImageRenderer(size: CGSize(width: 2400, height: 1200), format: format).image { context in
            UIColor.white.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 2400, height: 1200))
        }
        let data = try #require(ImageCompressor.jpegData(from: image))
        let decoded = try #require(UIImage(data: data))
        #expect(decoded.size.width * decoded.scale == 2000)
        #expect(decoded.size.height * decoded.scale == 1000)
    }
}

@MainActor
struct NextConcertTests {
    private let now = Date(timeIntervalSince1970: 1_800_000_000)
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Vienna")!
        return calendar
    }

    @Test func picksEarliestUpcomingDate() throws {
        let store = try TestStore()
        let later = store.addConcert("Später")
        later.date = now.addingTimeInterval(10 * 86_400)
        let sooner = store.addConcert("Bald")
        sooner.date = now.addingTimeInterval(2 * 86_400)
        let past = store.addConcert("Vorbei")
        past.date = now.addingTimeInterval(-5 * 86_400)

        let next = Concert.next(from: [later, sooner, past], now: now, calendar: calendar)
        #expect(next?.name == "Bald")
    }

    @Test func todayCountsAsUpcoming() throws {
        let store = try TestStore()
        let today = store.addConcert("Heute")
        today.date = calendar.startOfDay(for: now)
        #expect(Concert.next(from: [today], now: now, calendar: calendar)?.name == "Heute")
    }

    @Test func fallsBackToNewestUndatedConcert() throws {
        let store = try TestStore()
        let past = store.addConcert("Vorbei")
        past.date = now.addingTimeInterval(-5 * 86_400)
        let older = Concert(name: "Älter", createdAt: now.addingTimeInterval(-100))
        let newer = Concert(name: "Neuer", createdAt: now)
        store.context.insert(older)
        store.context.insert(newer)

        #expect(Concert.next(from: [past, older, newer], now: now, calendar: calendar)?.name == "Neuer")
    }

    @Test func noConcertWhenOnlyPastDates() throws {
        let store = try TestStore()
        let past = store.addConcert("Vorbei")
        past.date = now.addingTimeInterval(-5 * 86_400)
        #expect(Concert.next(from: [past], now: now, calendar: calendar) == nil)
    }
}
