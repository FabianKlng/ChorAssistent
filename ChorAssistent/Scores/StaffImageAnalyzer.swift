import CoreGraphics
import Foundation

/// Graustufenbild als Byte-Array (0 = schwarz, 255 = weiß), Zeile 0 = oben.
struct GrayImage: Sendable {
    let width: Int
    let height: Int
    let pixels: [UInt8]

    init?(cgImage: CGImage) {
        let w = cgImage.width
        let h = cgImage.height
        guard w > 0, h > 0 else { return nil }
        var buffer = [UInt8](repeating: 255, count: w * h)
        let drawn = buffer.withUnsafeMutableBytes { raw -> Bool in
            guard
                let context = CGContext(
                    data: raw.baseAddress, width: w, height: h, bitsPerComponent: 8, bytesPerRow: w,
                    space: CGColorSpaceCreateDeviceGray(), bitmapInfo: CGImageAlphaInfo.none.rawValue)
            else { return false }
            context.interpolationQuality = .none
            context.draw(cgImage, in: CGRect(x: 0, y: 0, width: w, height: h))
            return true
        }
        guard drawn else { return nil }
        width = w
        height = h
        pixels = buffer
    }
}

/// Ergebnis eines Tipps: gefundenes Notensystem und Position darin.
struct StaffDetection: Equatable, Sendable {
    /// y-Werte der fünf Linien in Bildpixeln, von oben nach unten.
    let lines: [Double]
    /// 0 = unterste Linie, positiv = höher.
    let step: Int
    /// Tipp-Position in Bildpixeln.
    let x: Double
    let y: Double

    var spacing: Double { (lines[4] - lines[0]) / 4 }
}

/// Findet die Notenlinien rund um einen Tipp.
///
/// Gemessen wird in vier schmalen senkrechten Streifen links und rechts der Tipp-Stelle
/// (der Notenkopf selbst zählt nicht mit). Schmale Streifen halten schiefe Scans aus:
/// Eine um 2° geneigte Linie wandert über 30 px nur um gut 1 px.
/// Pro Zeile wird die mittlere Dunkelheit bestimmt – relativ zu Papier- und Tintenton
/// des Ausschnitts, damit auch dünne, graue Linien aus JPEG-Scans zählen.
enum StaffImageAnalyzer {
    /// Mindest-Dunkelheit (0…1) einer Linie im Zeilenprofil.
    static let minLineDarkness = 0.35
    /// Mindestabstand zwischen Papier- und Tintenton, sonst ist der Ausschnitt leer.
    static let minContrast = 40.0

    static func detect(in image: GrayImage, x: Double, y: Double) -> StaffDetection? {
        let width = image.width
        let height = image.height
        let centerX = Int(x)
        let centerY = Int(y)
        guard (0..<width).contains(centerX), (0..<height).contains(centerY) else { return nil }

        let stripWidth = max(24, width / 60)
        let exclusion = max(10, width / 80)
        let reach = max(120, height / 12)
        let rows = max(0, centerY - reach)...min(height - 1, centerY + reach)

        let strips = [
            centerX - exclusion - stripWidth,
            centerX + exclusion,
            centerX - exclusion - 3 * stripWidth,
            centerX + exclusion + 2 * stripWidth,
        ].compactMap { start -> Range<Int>? in
            let low = max(0, start)
            let high = min(width, start + stripWidth)
            return high - low >= stripWidth / 2 ? low..<high : nil
        }
        guard !strips.isEmpty, let levels = inkAndPaper(in: image, rows: rows, strips: strips) else { return nil }

        var candidates: [Candidate] = []
        for strip in strips {
            let profile = darknessProfile(in: image, rows: rows, columns: strip, levels: levels)
            let lines = StaffDetector.lineCenters(
                darkness: profile, minDarkness: minLineDarkness, maxThickness: max(5, height / 400)
            )
            .map { $0 + Double(rows.lowerBound) }
            guard let staff = StaffDetector.staff(in: lines, near: y) else { continue }
            candidates.append(Candidate(staff: staff, distance: StaffDetector.distance(from: y, to: staff)))
        }
        guard let staff = vote(candidates)?.staff else { return nil }
        return StaffDetection(lines: staff, step: StaffPitch.step(forY: y, staff: staff), x: x, y: y)
    }

    private struct Candidate {
        let staff: [Double]
        let distance: Double
    }

    /// Das System, das die meisten Streifen übereinstimmend finden; bei Gleichstand das nächste.
    /// Eine Hilfslinie einer Nachbarnote verschiebt das System höchstens in einem Streifen.
    private static func vote(_ candidates: [Candidate]) -> Candidate? {
        func agree(_ a: [Double], _ b: [Double]) -> Bool {
            let tolerance = max(2, (a[4] - a[0]) / 8)
            return zip(a, b).allSatisfy { abs($0 - $1) <= tolerance }
        }
        let scored = candidates.map { candidate in
            (candidate, candidates.filter { agree($0.staff, candidate.staff) }.count)
        }
        return scored.max { lhs, rhs in
            lhs.1 != rhs.1 ? lhs.1 < rhs.1 : lhs.0.distance > rhs.0.distance
        }?.0
    }

    /// Tintenton (1 %-Quantil) und Papierton (90 %-Quantil) im Ausschnitt.
    /// Dünne Notenlinien belegen in einem Streifen nur wenige Prozent der Pixel.
    private static func inkAndPaper(in image: GrayImage, rows: ClosedRange<Int>, strips: [Range<Int>])
        -> (ink: Double, paper: Double)?
    {
        var histogram = [Int](repeating: 0, count: 256)
        var total = 0
        for row in rows {
            let base = row * image.width
            for strip in strips {
                for column in strip {
                    histogram[Int(image.pixels[base + column])] += 1
                    total += 1
                }
            }
        }
        guard total > 0 else { return nil }
        let ink = Double(quantile(histogram, total: total, fraction: 0.01))
        let paper = Double(quantile(histogram, total: total, fraction: 0.90))
        guard paper - ink >= minContrast else { return nil }
        return (ink, paper)
    }

    private static func quantile(_ histogram: [Int], total: Int, fraction: Double) -> Int {
        let target = Int(Double(total) * fraction)
        var sum = 0
        for (value, count) in histogram.enumerated() {
            sum += count
            if sum > target { return value }
        }
        return 255
    }

    /// Mittlere Dunkelheit pro Zeile (0 = Papier, 1 = Tinte).
    private static func darknessProfile(
        in image: GrayImage, rows: ClosedRange<Int>, columns: Range<Int>, levels: (ink: Double, paper: Double)
    ) -> [Double] {
        let range = levels.paper - levels.ink
        return rows.map { row in
            let base = row * image.width
            var sum = 0.0
            for column in columns {
                let value = Double(image.pixels[base + column])
                sum += min(1, max(0, (levels.paper - value) / range))
            }
            return sum / Double(columns.count)
        }
    }
}
