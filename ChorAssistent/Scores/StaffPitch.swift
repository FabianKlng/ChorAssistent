import Foundation

/// Notenschlüssel, die im Chor vorkommen.
enum Clef: String, CaseIterable, Identifiable, Sendable {
    case treble
    case trebleOctaveDown
    case bass

    var id: String { rawValue }

    var label: String {
        switch self {
        case .treble: return "Violin"
        case .trebleOctaveDown: return "Violin 8"
        case .bass: return "Bass"
        }
    }

    var symbol: String {
        switch self {
        case .treble: return "𝄞"
        case .trebleOctaveDown: return "𝄞₈"
        case .bass: return "𝄢"
        }
    }

    /// Diatonischer Index (Oktave · 7 + Stammton) der untersten Notenlinie.
    /// Violin: E4, Violin oktaviert (Tenor): E3, Bass: G2.
    var bottomLineDiatonic: Int {
        switch self {
        case .treble: return 4 * 7 + 2
        case .trebleOctaveDown: return 3 * 7 + 2
        case .bass: return 2 * 7 + 4
        }
    }
}

/// Umrechnung von Position im Notensystem zu MIDI.
enum StaffPitch {
    /// Halbtöne der Stammtöne C D E F G A H ab C.
    private static let letterSemitones = [0, 2, 4, 5, 7, 9, 11]
    /// Reihenfolge der Kreuze: F C G D A E H (als Stammton-Index).
    private static let sharpOrder = [3, 0, 4, 1, 5, 2, 6]
    /// Reihenfolge der Bs: H E A D G C F.
    private static let flatOrder = [6, 2, 5, 1, 4, 0, 3]

    static let keySignatureRange = -7...7

    /// Schritte über der untersten Linie: 0 = unterste Linie, 1 = Zwischenraum darüber, 8 = oberste Linie.
    static func step(forY y: Double, staff: [Double]) -> Int {
        let bottom = staff[staff.count - 1]
        let halfSpacing = (bottom - staff[0]) / 8
        guard halfSpacing > 0 else { return 0 }
        return Int(((bottom - y) / halfSpacing).rounded())
    }

    /// MIDI-Nummer für eine Position, einen Schlüssel und eine Tonart.
    /// `keySignature`: positiv = Anzahl ♯, negativ = Anzahl ♭.
    static func midi(step: Int, clef: Clef, keySignature: Int) -> Int {
        let diatonic = clef.bottomLineDiatonic + step
        let octave = Int((Double(diatonic) / 7).rounded(.down))
        let letter = diatonic - octave * 7
        let natural = (octave + 1) * 12 + letterSemitones[letter]
        return natural + alteration(letter: letter, keySignature: keySignature)
    }

    static func alteration(letter: Int, keySignature: Int) -> Int {
        if keySignature > 0, sharpOrder.prefix(keySignature).contains(letter) { return 1 }
        if keySignature < 0, flatOrder.prefix(-keySignature).contains(letter) { return -1 }
        return 0
    }

    static func keySignatureLabel(_ value: Int) -> String {
        let major = ["Ces", "Ges", "Des", "As", "Es", "B", "F", "C", "G", "D", "A", "E", "H", "Fis", "Cis"]
        let minor = ["as", "es", "b", "f", "c", "g", "d", "a", "e", "h", "fis", "cis", "gis", "dis", "ais"]
        let index = value + 7
        let keys = "\(major[index])-Dur / \(minor[index])-Moll"
        switch value {
        case 0: return "Keine (\(keys))"
        case let n where n > 0: return "\(n) ♯ (\(keys))"
        default: return "\(-value) ♭ (\(keys))"
        }
    }
}

/// Findet Notenlinien in einem Profil aus Zeilen-Dunkelwerten.
enum StaffDetector {
    /// Mittelpunkte zusammenhängender dunkler Zeilen.
    /// Sehr dicke Bänder (z. B. Balken, Flächen) werden verworfen.
    static func lineCenters(rowDarkness: [Double], minRatio: Double, maxThickness: Int = 12) -> [Double] {
        var centers: [Double] = []
        var runStart: Int?
        for (row, ratio) in rowDarkness.enumerated() {
            if ratio >= minRatio {
                if runStart == nil { runStart = row }
            } else if let start = runStart {
                appendRun(start: start, end: row - 1, maxThickness: maxThickness, to: &centers)
                runStart = nil
            }
        }
        if let start = runStart {
            appendRun(start: start, end: rowDarkness.count - 1, maxThickness: maxThickness, to: &centers)
        }
        return centers
    }

    private static func appendRun(start: Int, end: Int, maxThickness: Int, to centers: inout [Double]) {
        guard end - start + 1 <= maxThickness else { return }
        centers.append(Double(start + end) / 2)
    }

    /// Das Notensystem (fünf gleichmäßig verteilte Linien), das der Stelle `y` am nächsten liegt.
    /// Berücksichtigt Hilfslinien bis sechs Linienabstände über bzw. unter dem System.
    static func staff(in lines: [Double], near y: Double, maxGapRatio: Double = 1.35, minGap: Double = 3)
        -> [Double]?
    {
        guard lines.count >= 5 else { return nil }
        var best: (staff: [Double], distance: Double)?
        for start in 0...(lines.count - 5) {
            let group = Array(lines[start..<(start + 5)])
            let gaps = zip(group.dropFirst(), group).map { $0 - $1 }
            guard let smallest = gaps.min(), let largest = gaps.max(), smallest >= minGap,
                largest / smallest <= maxGapRatio
            else { continue }
            let spacing = (group[4] - group[0]) / 4
            let distance: Double
            if y < group[0] {
                distance = group[0] - y
            } else if y > group[4] {
                distance = y - group[4]
            } else {
                distance = 0
            }
            guard distance <= spacing * 6 else { continue }
            if best == nil || distance < best!.distance {
                best = (group, distance)
            }
        }
        return best?.staff
    }
}
