import Foundation
import SwiftData

@testable import ChorAssistent

/// In-Memory-Datenbank für Tests. Der Container muss leben, solange der Kontext benutzt wird.
@MainActor
struct TestStore {
    let container: ModelContainer
    var context: ModelContext { container.mainContext }

    init() throws {
        container = try ModelContainer(
            for: Song.self, Concert.self, ConcertEntry.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
    }

    @discardableResult
    func addSong(_ title: String, _ pitches: [Int] = [60], memo: String = "") -> Song {
        let song = Song(
            title: title, memo: memo, pitches: pitches, createdAt: Date(timeIntervalSince1970: 1_700_000_000))
        context.insert(song)
        return song
    }

    @discardableResult
    func addConcert(_ name: String) -> Concert {
        let concert = Concert(name: name, createdAt: Date(timeIntervalSince1970: 1_700_000_000))
        context.insert(concert)
        return concert
    }
}

/// Eigene UserDefaults pro Test, damit Tests sich nicht beeinflussen.
func makeTestDefaults() -> UserDefaults {
    let name = "ChorAssistentTests-\(UUID().uuidString)"
    let defaults = UserDefaults(suiteName: name)!
    defaults.removePersistentDomain(forName: name)
    PlaybackSettings.registerDefaults(defaults)
    return defaults
}

func temporaryFileURL(_ name: String = "test.json") -> URL {
    FileManager.default.temporaryDirectory
        .appending(path: "ChorAssistentTests-\(UUID().uuidString)")
        .appending(path: name)
}
