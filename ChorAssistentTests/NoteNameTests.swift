import Testing

@testable import ChorAssistent

struct NoteNameTests {
    @Test(arguments: [
        (60, "C4"), (69, "A4"), (70, "B4"), (71, "H4"), (66, "Fis4"), (36, "C2"), (84, "C6"),
    ])
    func nameForMidi(midi: Int, expected: String) {
        #expect(NoteName.name(midi: midi) == expected)
    }

    @Test func pickerLabels() {
        #expect(NoteName.pickerLabels.count == 12)
        #expect(NoteName.pickerLabel(pitchClass: 0) == "C")
        #expect(NoteName.pickerLabel(pitchClass: 1) == "Cis/Des")
        #expect(NoteName.pickerLabel(pitchClass: 3) == "Dis/Es")
        #expect(NoteName.pickerLabel(pitchClass: 6) == "Fis/Ges")
        #expect(NoteName.pickerLabel(pitchClass: 8) == "Gis/As")
        #expect(NoteName.pickerLabel(pitchClass: 10) == "B (= B♭)")
        #expect(NoteName.pickerLabel(pitchClass: 11) == "H (= B)")
    }

    @Test func roundTripOverAllowedRange() {
        for midi in 36...84 {
            let parts = NoteName.components(midi: midi)
            #expect(NoteName.midi(pitchClass: parts.pitchClass, octave: parts.octave) == midi)
        }
    }

    @Test func namesAreJoinedWithComma() {
        #expect(NoteName.names([62, 66, 69]) == "D4, Fis4, A4")
        #expect(NoteName.names([]) == "")
    }
}
