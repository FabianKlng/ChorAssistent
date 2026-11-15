import Foundation

enum NoteEventKind: Equatable {
    case start
    case stop
}

struct NoteEvent: Equatable {
    let timeMs: Int
    let midi: Int
    let kind: NoteEventKind
}

/// Reine Berechnung des Ablaufs in ganzen Millisekunden, ohne Audio.
enum PlaybackSchedule {
    /// Ton i startet bei `i * (toneDurationMs + gapMs)` und stoppt `toneDurationMs` später.
    /// Sortiert nach Zeit; bei gleicher Zeit steht `stop` vor `start`, damit ein
    /// wiederholter Ton bei Pause 0 den folgenden nicht abschneidet.
    static func events(pitches: [Int], toneDurationMs: Int, gapMs: Int) -> [NoteEvent] {
        let step = toneDurationMs + gapMs
        var events: [NoteEvent] = []
        events.reserveCapacity(pitches.count * 2)
        for (index, midi) in pitches.enumerated() {
            let start = index * step
            events.append(NoteEvent(timeMs: start, midi: midi, kind: .start))
            events.append(NoteEvent(timeMs: start + toneDurationMs, midi: midi, kind: .stop))
        }
        return events.sorted { lhs, rhs in
            if lhs.timeMs != rhs.timeMs { return lhs.timeMs < rhs.timeMs }
            return lhs.kind == .stop && rhs.kind == .start
        }
    }
}
