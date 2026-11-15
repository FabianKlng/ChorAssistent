import Testing

@testable import ChorAssistent

struct SongValidationTests {
    @Test func emptyTitle() {
        #expect(Song.validate(title: "", pitches: [60]) == .emptyTitle)
        #expect(Song.validate(title: "   ", pitches: [60]) == .emptyTitle)
    }

    @Test func pitchCount() {
        #expect(Song.validate(title: "A", pitches: []) == .noPitches)
        #expect(Song.validate(title: "A", pitches: Array(repeating: 60, count: 9)) == .tooManyPitches)
    }

    @Test func pitchRange() {
        #expect(Song.validate(title: "A", pitches: [35]) == .pitchOutOfRange(35))
        #expect(Song.validate(title: "A", pitches: [85]) == .pitchOutOfRange(85))
    }

    @Test func validLimits() {
        #expect(Song.validate(title: "A", pitches: [36]) == nil)
        #expect(Song.validate(title: "A", pitches: [84]) == nil)
        #expect(Song.validate(title: "A", pitches: Array(repeating: 60, count: 8)) == nil)
    }
}
