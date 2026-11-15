import Foundation
import SwiftData

/// Eine gescannte Notenseite eines Lieds (JPEG).
@Model
final class ScorePage {
    var id: UUID
    /// Reihenfolge der Seiten; neue Seiten kommen ans Ende.
    var pageNumber: Int
    /// Wird außerhalb der Datenbankdatei gespeichert.
    @Attribute(.externalStorage) var imageData: Data
    var createdAt: Date
    var song: Song?

    init(id: UUID = UUID(), pageNumber: Int, imageData: Data, createdAt: Date = .now) {
        self.id = id
        self.pageNumber = pageNumber
        self.imageData = imageData
        self.createdAt = createdAt
    }
}

extension Song {
    var sortedScorePages: [ScorePage] {
        scorePages
            .filter { !$0.isDeleted }
            .sorted { ($0.pageNumber, $0.createdAt) < ($1.pageNumber, $1.createdAt) }
    }

    /// Hängt eine Seite hinten an.
    @discardableResult
    func addScorePage(_ imageData: Data, in context: ModelContext) -> ScorePage {
        let next = (sortedScorePages.last?.pageNumber ?? 0) + 1
        let page = ScorePage(pageNumber: next, imageData: imageData)
        context.insert(page)
        page.song = self
        return page
    }
}
