import SwiftUI

/// Auswahl eines Tons über Tonname- und Oktav-Rad (C2–C6).
struct PitchPicker: View {
    let onDone: (Int) -> Void

    @Environment(\.dismiss) private var dismiss
    @Environment(TonePlayer.self) private var tonePlayer

    @State private var pitchClass: Int
    @State private var octave: Int

    static let octaves = Array(2...6)
    static let topOctave = 6

    init(initialMidi: Int, onDone: @escaping (Int) -> Void) {
        self.onDone = onDone
        let clamped = min(max(initialMidi, Song.pitchRange.lowerBound), Song.pitchRange.upperBound)
        let parts = NoteName.components(midi: clamped)
        _pitchClass = State(initialValue: parts.pitchClass)
        _octave = State(initialValue: parts.octave)
    }

    private var midi: Int { NoteName.midi(pitchClass: pitchClass, octave: octave) }

    /// In Oktave 6 ist nur C erlaubt, damit kein Ton über C6 entsteht.
    private var availablePitchClasses: [Int] {
        octave == Self.topOctave ? [0] : Array(0..<12)
    }

    var body: some View {
        NavigationStack {
            HStack(spacing: 0) {
                Picker("Ton", selection: $pitchClass) {
                    ForEach(availablePitchClasses, id: \.self) { pc in
                        Text(NoteName.pickerLabel(pitchClass: pc)).tag(pc)
                    }
                }
                .pickerStyle(.wheel)

                Picker("Oktave", selection: $octave) {
                    ForEach(Self.octaves, id: \.self) { value in
                        Text("\(value)").tag(value)
                    }
                }
                .pickerStyle(.wheel)
                .frame(width: 90)
            }
            .padding(.horizontal)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Theme.paper)
            .navigationTitle(NoteName.name(midi: midi))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fertig") {
                        onDone(midi)
                        dismiss()
                    }
                }
            }
            .onChange(of: octave) { _, newOctave in
                if newOctave == Self.topOctave {
                    pitchClass = 0
                }
                tonePlayer.preview(midi)
            }
            .onChange(of: pitchClass) { _, _ in
                tonePlayer.preview(midi)
            }
        }
        .presentationDetents([.medium])
    }
}
