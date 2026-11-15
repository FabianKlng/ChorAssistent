import Foundation

/// Die einzige Stelle, an der aus MIDI-Nummern Notennamen werden.
/// Deutsche Schreibweise: B = B♭ (MIDI 70), H = B (MIDI 71). C4 = MIDI 60.
enum NoteName {
    static let pitchClasses = ["C", "Cis", "D", "Dis", "E", "F", "Fis", "G", "Gis", "A", "B", "H"]

    /// Labels nur für das Auswahlrad: Doppelnamen für Töne mit Vorzeichen.
    static let pickerLabels = [
        "C", "Cis/Des", "D", "Dis/Es", "E", "F", "Fis/Ges", "G", "Gis/As", "A", "B (= B♭)", "H (= B)",
    ]

    static func name(midi: Int) -> String {
        let parts = components(midi: midi)
        return pitchClasses[parts.pitchClass] + String(parts.octave)
    }

    static func pickerLabel(pitchClass: Int) -> String {
        pickerLabels[pitchClass]
    }

    static func midi(pitchClass: Int, octave: Int) -> Int {
        (octave + 1) * 12 + pitchClass
    }

    static func components(midi: Int) -> (pitchClass: Int, octave: Int) {
        (pitchClass: midi % 12, octave: midi / 12 - 1)
    }

    static func names(_ pitches: [Int]) -> String {
        pitches.map { name(midi: $0) }.joined(separator: ", ")
    }
}
