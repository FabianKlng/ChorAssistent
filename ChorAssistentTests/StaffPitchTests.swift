import CoreGraphics
import Foundation
import Testing
import UIKit

@testable import ChorAssistent

struct StaffPitchTests {
    // MARK: Schlüssel

    @Test(arguments: [
        (Clef.treble, 0, 64), (Clef.treble, 8, 77), (Clef.treble, -2, 60), (Clef.treble, 3, 69),
        (Clef.trebleOctaveDown, 0, 52), (Clef.trebleOctaveDown, 3, 57),
        (Clef.bass, 0, 43), (Clef.bass, 8, 57), (Clef.bass, 6, 53),
    ])
    func positionsWithoutKeySignature(clef: Clef, step: Int, expected: Int) {
        #expect(StaffPitch.midi(step: step, clef: clef, keySignature: 0) == expected)
    }

    // MARK: Vorzeichen

    @Test func gMajorRaisesF() {
        // Violinschlüssel, erster Zwischenraum = F4 → Fis4
        #expect(StaffPitch.midi(step: 1, clef: .treble, keySignature: 1) == 66)
        // C bleibt in G-Dur unverändert
        #expect(StaffPitch.midi(step: -2, clef: .treble, keySignature: 1) == 60)
    }

    @Test func fMajorLowersB() {
        // Violinschlüssel, mittlere Linie = H4 → B4
        #expect(StaffPitch.midi(step: 4, clef: .treble, keySignature: -1) == 70)
    }

    @Test func eFlatMajorLowersBEAndA() {
        #expect(StaffPitch.midi(step: 4, clef: .treble, keySignature: -3) == 70)  // B4
        #expect(StaffPitch.midi(step: 0, clef: .treble, keySignature: -3) == 63)  // Es4
        #expect(StaffPitch.midi(step: 3, clef: .treble, keySignature: -3) == 68)  // As4
        #expect(StaffPitch.midi(step: 2, clef: .treble, keySignature: -3) == 67)  // G4 bleibt
    }

    @Test func keySignatureLabels() {
        #expect(StaffPitch.keySignatureLabel(0) == "Keine (C-Dur / a-Moll)")
        #expect(StaffPitch.keySignatureLabel(2) == "2 ♯ (D-Dur / h-Moll)")
        #expect(StaffPitch.keySignatureLabel(-3) == "3 ♭ (Es-Dur / c-Moll)")
    }

    // MARK: Position im System

    @Test func stepFromY() {
        let staff: [Double] = [200, 220, 240, 260, 280]
        #expect(StaffPitch.step(forY: 280, staff: staff) == 0)
        #expect(StaffPitch.step(forY: 270, staff: staff) == 1)
        #expect(StaffPitch.step(forY: 200, staff: staff) == 8)
        #expect(StaffPitch.step(forY: 300, staff: staff) == -2)
        #expect(StaffPitch.step(forY: 273, staff: staff) == 1)  // leicht daneben getippt
    }

    // MARK: Linien finden

    @Test func lineCentersMergeRunsAndSkipThickBands() {
        var profile = [Double](repeating: 0, count: 60)
        profile[10] = 0.9
        profile[11] = 0.9  // Linie bei 10,5
        profile[20] = 0.6  // Linie bei 20
        for row in 30..<50 { profile[row] = 0.9 }  // dickes Band → verworfen
        #expect(StaffDetector.lineCenters(rowDarkness: profile, minRatio: 0.45) == [10.5, 20])
    }

    @Test func staffPicksEvenlySpacedGroupNearestToTap() {
        let upper: [Double] = [100, 120, 140, 160, 180]
        let lower: [Double] = [300, 320, 340, 360, 380]
        let lines = upper + lower
        #expect(StaffDetector.staff(in: lines, near: 150) == upper)
        #expect(StaffDetector.staff(in: lines, near: 395) == lower)  // Hilfslinie unter dem System
        #expect(StaffDetector.staff(in: lines, near: 240) == upper)  // näher am oberen System
    }

    @Test func staffRejectsUnevenGroups() {
        #expect(StaffDetector.staff(in: [100, 110, 140, 150, 200], near: 120) == nil)
        #expect(StaffDetector.staff(in: [100, 120, 140], near: 120) == nil)
    }

    // MARK: Ende zu Ende mit gezeichnetem Notenbild

    @Test func detectsNoteOnSyntheticStaff() throws {
        let gray = try #require(makeStaffImage(noteCenter: CGPoint(x: 600, y: 250)))
        // Notenkopf im 3. Zwischenraum von unten → Schritt 3 → A4 im Violinschlüssel
        let detection = try #require(StaffImageAnalyzer.detect(in: gray, x: 600, y: 250))
        #expect(detection.step == 3)
        #expect(abs(detection.spacing - 20) < 1.5)
        #expect(StaffPitch.midi(step: detection.step, clef: .treble, keySignature: 0) == 69)
    }

    @Test func detectsLedgerLineNoteBelowStaff() throws {
        let gray = try #require(makeStaffImage(noteCenter: CGPoint(x: 500, y: 300)))
        // Hilfslinie unter dem System → Schritt −2 → C4
        let detection = try #require(StaffImageAnalyzer.detect(in: gray, x: 500, y: 300))
        #expect(detection.step == -2)
        #expect(StaffPitch.midi(step: detection.step, clef: .treble, keySignature: 0) == 60)
    }

    @Test func returnsNilOnEmptyPage() throws {
        let gray = try #require(makeStaffImage(noteCenter: nil, drawStaff: false))
        #expect(StaffImageAnalyzer.detect(in: gray, x: 600, y: 250) == nil)
    }

    /// Weißes Bild 1200×600 mit Notensystem (Linien bei y = 200…280, Abstand 20) und optionalem Notenkopf.
    private func makeStaffImage(noteCenter: CGPoint?, drawStaff: Bool = true) -> GrayImage? {
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1
        let size = CGSize(width: 1200, height: 600)
        let image = UIGraphicsImageRenderer(size: size, format: format).image { context in
            UIColor.white.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            UIColor.black.setFill()
            if drawStaff {
                for index in 0..<5 {
                    let y = 200 + CGFloat(index) * 20
                    context.fill(CGRect(x: 40, y: y - 1, width: 1120, height: 2))
                }
            }
            if let noteCenter {
                context.cgContext.fillEllipse(
                    in: CGRect(x: noteCenter.x - 13, y: noteCenter.y - 9, width: 26, height: 18))
                // Hilfslinie für Noten unterhalb des Systems
                if noteCenter.y >= 300 {
                    context.fill(CGRect(x: noteCenter.x - 22, y: 299, width: 44, height: 2))
                }
            }
        }
        guard let cgImage = image.cgImage else { return nil }
        return GrayImage(cgImage: cgImage)
    }
}
