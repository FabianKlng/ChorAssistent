import Testing

@testable import ChorAssistent

struct PlaybackScheduleTests {
    @Test func threeTonesWithGap() {
        let events = PlaybackSchedule.events(pitches: [62, 66, 69], toneDurationMs: 1000, gapMs: 150)
        let starts = events.filter { $0.kind == .start }.map(\.timeMs)
        let stops = events.filter { $0.kind == .stop }.map(\.timeMs)
        #expect(starts == [0, 1150, 2300])
        #expect(stops == [1000, 2150, 3300])
    }

    @Test func emptyListHasNoEvents() {
        #expect(PlaybackSchedule.events(pitches: [], toneDurationMs: 1000, gapMs: 150).isEmpty)
    }

    @Test func noOverlapWithZeroGap() {
        let events = PlaybackSchedule.events(pitches: [60, 64, 67], toneDurationMs: 800, gapMs: 0)
        let starts = events.filter { $0.kind == .start }.map(\.timeMs)
        let stops = events.filter { $0.kind == .stop }.map(\.timeMs)
        for index in 0..<(starts.count - 1) {
            #expect(stops[index] <= starts[index + 1])
        }
    }

    @Test func repeatedPitchStopsBeforeNextStart() {
        let events = PlaybackSchedule.events(pitches: [60, 60], toneDurationMs: 500, gapMs: 0)
        #expect(
            events == [
                NoteEvent(timeMs: 0, midi: 60, kind: .start),
                NoteEvent(timeMs: 500, midi: 60, kind: .stop),
                NoteEvent(timeMs: 500, midi: 60, kind: .start),
                NoteEvent(timeMs: 1000, midi: 60, kind: .stop),
            ])
    }
}
